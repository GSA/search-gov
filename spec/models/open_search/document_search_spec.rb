# frozen_string_literal: true

require 'spec_helper'

describe OpenSearch::DocumentSearch do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_options) do
    {
      indices: ['test_index'],
      query: 'electro coagulation',
      size: 10,
      offset: 0
    }
  end

  describe '#search' do
    let(:search) { described_class.new(search_options, affiliate: affiliate) }
    let(:search_results) do
      {
        'hits' => {
          'total' => 100,
          'hits' => []
        }
      }
    end

    before do
      allow(OPENSEARCH_CLIENT).to receive(:search).and_return(search_results)
    end

    it 'returns an OpenSearch::DocumentSearchResults object' do
      expect(search.search).to be_a(OpenSearch::DocumentSearchResults)
    end

    it 'calls the search client with the correct arguments' do
      search.search
      expect(OPENSEARCH_CLIENT).to have_received(:search).with(
        index: ['test_index'],
        body: anything,
        from: 0,
        size: 10,
        rest_total_hits_as_int: true
      )
    end

    describe 'query result caching' do
      let(:cache) { ActiveSupport::Cache::MemoryStore.new }
      let(:cache_on) { 'true' }
      let(:cache_duration) { nil }

      around do |example|
        saved = ENV.to_h.slice('REDIS_CACHE_ON', 'REDIS_CACHE_DURATION')
        ENV['REDIS_CACHE_ON'] = cache_on
        ENV['REDIS_CACHE_DURATION'] = cache_duration
        example.run
      ensure
        ENV['REDIS_CACHE_ON'] = saved['REDIS_CACHE_ON']
        ENV['REDIS_CACHE_DURATION'] = saved['REDIS_CACHE_DURATION']
      end

      before do
        allow(Rails).to receive(:cache).and_return(cache)
        affiliate.search_cache_enabled = true
      end

      def search_with(options = search_options, site: affiliate)
        described_class.new(options, affiliate: site).tap(&:search)
      end

      def expect_client_calls(count)
        expect(OPENSEARCH_CLIENT).to have_received(:search).exactly(count).times
      end

      it 'queries OpenSearch on a miss and serves the cache on a hit' do
        first = search_with
        second = search_with

        expect_client_calls(1)
        expect(first.cache_status).to eq('miss')
        expect(second.cache_status).to eq('hit')
      end

      it 'stores entries in the searches namespace under an affiliate-prefixed, versioned key' do
        search_with

        key = cache.instance_variable_get(:@data).keys.first
        expect(key).to start_with("searches:#{affiliate.id}:v1:")
      end

      context 'with Redis' do
        let(:redis_url) { ENV.fetch('REDIS_SYSTEM_URL', 'redis://localhost:6379').sub(%r{/\d*\z}, '') + '/15' }
        let(:cache) { ActiveSupport::Cache::RedisCacheStore.new(url: redis_url) }
        let(:other) { affiliates(:another_affiliate).tap { |site| site.search_cache_enabled = true } }

        after { cache.delete_matched('*', namespace: 'searches') }

        it 'flushes one affiliate with the documented command without touching another' do
          search_with
          search_with(site: other)

          cache.delete_matched("#{affiliate.id}:*", namespace: 'searches')
          search_with
          search_with(site: other)

          expect_client_calls(3)
        end
      end

      it 'expires entries after REDIS_CACHE_DURATION minutes' do
        search_with
        travel(16.minutes) { search_with }

        expect_client_calls(2)
      end

      it 'caches empty results' do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_return(described_class::NO_HITS)
        2.times { search_with }

        expect_client_calls(1)
      end

      it 'caches a plain Hash that survives Marshal' do
        search_with

        entry = cache.read(cache.instance_variable_get(:@data).keys.first.delete_prefix('searches:'),
                           namespace: 'searches')
        expect(entry).to be_a(Hash)
        expect(Marshal.load(Marshal.dump(entry))).to eq(search_results)
      end

      it 'does not cache a raised client error' do
        allow(OPENSEARCH_CLIENT).to receive(:search).and_raise(StandardError, 'boom')
        expect { search_with }.to raise_error(StandardError, 'boom')

        allow(OPENSEARCH_CLIENT).to receive(:search).and_return(search_results)
        search_with

        expect_client_calls(2)
      end

      it 'passes the same body to OpenSearch that it keys on' do
        search_with

        expect(OPENSEARCH_CLIENT).to have_received(:search).with(hash_including(body: a_kind_of(Hash)))
      end

      describe 'enablement gate' do
        shared_examples 'cache skipped' do |label|
          it "queries OpenSearch every time and reports #{label}" do
            first = search_with
            second = search_with

            expect_client_calls(2)
            expect([first.cache_status, second.cache_status]).to eq([label, label])
            expect(cache.instance_variable_get(:@data)).to be_empty
          end
        end

        [nil, '', 'false', 'yes', '1'].each do |value|
          context "when REDIS_CACHE_ON is #{value.inspect}" do
            let(:cache_on) { value }

            it_behaves_like 'cache skipped', 'disabled'
          end
        end

        context 'when REDIS_CACHE_ON is TRUE with padding' do
          let(:cache_on) { ' TRUE ' }

          it 'caches' do
            2.times { search_with }
            expect_client_calls(1)
          end
        end

        context 'when the affiliate has not enabled the cache' do
          before { affiliate.search_cache_enabled = false }

          it_behaves_like 'cache skipped', 'disabled'
        end

        %w[0 -5].each do |value|
          context "when REDIS_CACHE_DURATION is #{value}" do
            let(:cache_duration) { value }

            it_behaves_like 'cache skipped', 'disabled'
          end
        end

        %w[abc 15.5 015].each do |value|
          context "when REDIS_CACHE_DURATION is #{value.inspect}" do
            let(:cache_duration) { value }

            it 'uses a whole-minute duration and still caches' do
              search_with
              travel(14.minutes) { search_with }
              expect_client_calls(1)
            end
          end
        end

        context 'when a legacy skip_cache option is passed' do
          it 'ignores it and reads the cache' do
            search_with
            second = search_with(search_options.merge(skip_cache: true))

            expect(second.cache_status).to eq('hit')
            expect_client_calls(1)
          end
        end
      end

      describe 'cache key' do
        def calls_for(*queries, **overrides)
          queries.each { |query| search_with(search_options.merge(query:, **overrides)) }
          OPENSEARCH_CLIENT
        end

        it 'folds query case and whitespace' do
          calls_for('Electro Coagulation', 'ELECTRO   coagulation', ' electro coagulation ')
          expect_client_calls(1)
        end

        it 'keeps uppercase boolean operators distinct from lowercase words' do
          calls_for('taxes OR benefits', 'taxes or benefits')
          expect_client_calls(2)
        end

        it 'folds case inside quoted phrases' do
          calls_for('"Social Security"', '"social security"')
          expect_client_calls(1)
        end

        it 'folds accented capitals' do
          calls_for('ÉTÉ', 'été')
          expect_client_calls(1)
        end

        it 'keeps the Turkish dotted capital I distinct from a plain i' do
          calls_for('İstanbul', 'istanbul')
          expect_client_calls(2)
        end

        it 'keeps site path filters case-sensitive' do
          calls_for('foo site:justice.gov/OPA', 'foo site:justice.gov/opa')
          expect_client_calls(2)
        end

        it 'folds the query while keeping the same site filter' do
          calls_for('Foo site:justice.gov/OPA', 'foo site:justice.gov/OPA')
          expect_client_calls(1)
        end

        it 'treats a missing offset as offset 0' do
          search_with(search_options.except(:offset))
          search_with
          expect_client_calls(1)
        end

        it 'separates offsets, sizes, indices, and affiliates' do
          search_with
          search_with(search_options.merge(offset: 20))
          search_with(search_options.merge(size: 20))
          search_with(search_options.merge(indices: ['legacy_index']))
          other = affiliates(:another_affiliate).tap { |site| site.search_cache_enabled = true }
          search_with(site: other)

          expect_client_calls(5)
        end

        {
          sort_by_date: 1,
          language: 'es',
          include: %w[title path],
          ignore_tags: %w[archived],
          tags: %w[health],
          audience: %w[veterans],
          content_type: %w[article],
          mime_type: %w[application/pdf],
          searchgov_custom1: %w[a],
          searchgov_custom2: %w[b],
          searchgov_custom3: %w[c],
          min_timestamp: Time.utc(2026, 1, 1),
          max_timestamp: Time.utc(2026, 2, 1),
          min_timestamp_created: Time.utc(2026, 1, 1),
          max_timestamp_created: Time.utc(2026, 2, 1)
        }.each do |option, value|
          it "changes when #{option} changes" do
            search_with
            search_with(search_options.merge(option => value))
            expect_client_calls(2)
          end
        end

        it 'changes when the affiliate searches all domains' do
          search_with(search_options.merge(query: 'foo site:justice.gov'))
          affiliate.gets_results_from_all_domains = true
          search_with(search_options.merge(query: 'foo site:justice.gov'))
          expect_client_calls(2)
        end

        it 'floors timestamps to the minute so relative ranges stay cacheable' do
          search_with(search_options.merge(min_timestamp: Time.utc(2026, 9, 27, 10, 1, 5)))
          search_with(search_options.merge(min_timestamp: Time.utc(2026, 9, 27, 10, 1, 50)))
          search_with(search_options.merge(min_timestamp: Time.utc(2026, 9, 27, 10, 2, 5)))
          expect_client_calls(2)
        end
      end

      context 'when Redis is unreachable' do
        let(:warnings) { [] }
        let(:cache) do
          ActiveSupport::Cache::RedisCacheStore.new(
            url: 'redis://127.0.0.1:1',
            connect_timeout: 0.1,
            reconnect_attempts: 0,
            error_handler: ->(method:, exception:, **) { warnings << [method, exception.class] }
          )
        end

        it 'fails open and returns OpenSearch results' do
          result = described_class.new(search_options, affiliate: affiliate).search

          expect(result.total).to eq(100)
          expect_client_calls(1)
          expect(warnings).not_to be_empty
        end
      end
    end

    describe '.normalize_query' do
      it 'downcases terms, keeps uppercase operators, and squishes whitespace' do
        expect(described_class.normalize_query('  Taxes  AND Benefits NOT Or ')).to eq('taxes AND benefits NOT or')
      end
    end

    context 'when a result title is a percent-encoded filename' do
      let(:search_results) do
        {
          'hits' => {
            'total' => 1,
            'hits' => [
              { '_source' => { 'path' => 'https://www.va.gov/files/2022-10/BA%20degree%20nurse%20scholarship_0.pdf',
                               'language' => 'en',
                               'title_en' => 'BA%20degree%20nurse%20scholarship_0.pdf' } }
            ]
          }
        }
      end

      it 'decodes the title for downstream SERP and API consumers' do
        expect(search.search.results.first['title']).to eq('BA degree nurse scholarship_0.pdf')
      end
    end
  end
end

require 'spec_helper'

describe ApiAzureSearch do
  #disabling until tests are removed:
  #https://www.pivotaltracker.com/story/show/134719601

  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:search_params) do
    { affiliate: affiliate,
      api_key: api_key,
      enable_highlighting: true,
      limit: 20,
      next_offset_within_limit: true,
      offset: 0,
      query: 'government agency' }
  end
  let(:search) { ApiAzureSearch.new search_params }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  context 'when initialized with a Bing V2 key' do
    let(:api_key) { AzureEngine::DEFAULT_AZURE_HOSTED_PASSWORD }

    it_should_behave_like 'a commercial API search'

    skip '#new' do
      before do
        affiliate.site_domains.create!(domain: 'whitehouse.gov')
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
      end

      it 'initializes AzureWebEngine' do
        expect(AzureWebEngine).to_receive(:new).
          with(enable_highlighting: true,
               limit: 20,
               next_offset_within_limit: true,
               offset: 0,
               language: 'en',
               password: api_key,
               query: 'government agency (site:whitehouse.gov OR site:usa.gov) (-site:kids.usa.gov)')

        described_class.new(search_params)
      end
    end

    skip '#run' do
      context 'when offset is 0' do
        it 'initializes GovboxSet' do
          highlighting_options = {
            highlighting: true,
            pre_tags: ["\ue000"],
            post_tags: ["\ue001"]
          }

          expect(GovboxSet).to receive(:new).with(
            'government agency',
            affiliate,
            nil,
            highlighting_options)

          described_class.new(search_params).run
        end
      end

      context 'when offset is not 0' do
        before { search_params[:offset] = 666 }

        it 'does not initialize GovboxSet' do
          expect(GovboxSet).not_to receive(:new)

          described_class.new(search_params).run
        end
      end

      context 'when enable_highlighting is enabled' do
        subject(:search) { described_class.new(search_params) }

        before { search.run }

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'highlights title and description' do
          result = search.results.first
          expect(result.title).to match(/\ue000.+\ue001/)
          expect(result.description).to match(/\ue000.+\ue001/)
          expect(result.url).to match(URI.regexp)
        end

        it 'does not highlight display_url' do
          expect(search.results.first.display_url).to_not match(/\ue000.+\ue001/)
        end

        its(:next_offset) { is_expected.to eq(20) }
        its(:modules) { is_expected.to include('AWEB') }
      end

      context 'when enable_highlighting is disabled' do
        subject(:search) do
          described_class.new(search_params.merge({enable_highlighting: false}))
        end

        before { search.run }

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'does not highlight the title and description' do
          result = search.results.first
          expect(result.title).to match(/government/i)
          expect(result.title).to_not match(/\ue000.+\ue001/)
          expect(result.description).to match(/government/i)
          expect(result.description).to_not match(/\ue000.+\ue001/)
        end

        its(:next_offset) { is_expected.to eq(20) }
        its(:modules) { is_expected.to include('AWEB') }
      end

      context 'when response _next is not present' do
        subject(:search) do
          described_class.new(search_params.merge({query: 'azure no next'}))
        end

        before do
          affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
          affiliate.excluded_domains.create!(domain: 'www.usa.gov')
          no_next_result = Rails.root.join('spec/fixtures/json/azure/image_spell/no_next.json').read
          stub_request(:get, /#{AzureEngine::API_HOST}.*azure no next/).
            to_return(status: 200, body: no_next_result)
          search.run
        end

        its(:next_offset) { is_expected.to be_nil }
      end

      context 'when the site locale is es' do
        let(:search) do
          described_class.new(search_params.merge( {query: 'educación'}))
        end

        before do
          allow(Language).to receive(:find_by_code).with('es').and_return(
            mock_model(Language, is_azure_supported: true, inferred_country_code: 'US')
          )
          affiliate.locale = 'es'
          search.run
        end

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'highlights title and description' do
          result = search.results[0]
          expect(result.title).to match(/\ue000.+\ue001/)
          expect(result.description).to match(/\ue000.+\ue001/)
        end

        it 'does not hightlight display_url' do
          expect(search.results.first.display_url).to_not match(/\ue000.+\ue001/)
        end
      end

      context 'when Azure response contains empty results' do
        subject(:search) do
          described_class.new(search_params.merge( {query: 'mango smoothie'}))
        end

        before { search.run }

        its(:results) { is_expected.to be_empty }
        its(:modules) { is_expected.not_to include('AWEB') }
      end
    end

    skip '#as_json' do
      subject(:search) do
        agency = Agency.create!({:name => 'Some New Agency', :abbreviation => 'SNA' })
        AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
        affiliate.stub(:agency).and_return(agency)

        described_class.new search_params
      end

      before { search.run }

      it 'returns results' do
        expect(search.as_json[:web][:results].count).to eq(20)
      end

      it 'highlights title and description' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.snippet).to match(/\ue000.+\ue001/)
        expect(result.url).to match(URI.regexp)
      end

      it 'does not hightlight display_url' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.display_url).to_not match(/\ue000.+\ue001/)
      end

      it_should_behave_like 'an API search as_json'
      it_should_behave_like 'a commercial API search as_json'
    end
  end

  context 'when initialized with a Bing V5 key' do
      let(:api_key) { BingV5HostedSubscriptionKey::BING_V5_SUBSCRIPTION_KEY }

    it_should_behave_like 'a commercial API search'

    skip '#new' do
      before do
        affiliate.site_domains.create!(domain: 'whitehouse.gov')
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
      end

      it 'initializes AzureWebEngine' do
        expect(BingV5WebEngine).to receive(:new).
          with(enable_highlighting: true,
               limit: 20,
               next_offset_within_limit: true,
               offset: 0,
               language: 'en',
               password: api_key,
               query: 'government agency (site:whitehouse.gov OR site:usa.gov) (-site:kids.usa.gov)')

        described_class.new(search_params)
      end
    end

    skip '#run' do
      context 'when offset is 0' do
        it 'initializes GovboxSet' do
          highlighting_options = {
            highlighting: true,
            pre_tags: ["\ue000"],
            post_tags: ["\ue001"]
          }

          expect(GovboxSet).to receive(:new).with(
            'government agency',
            affiliate,
            nil,
            highlighting_options)

          described_class.new(search_params).run
        end
      end

      context 'when offset is not 0' do
        before { search_params[:offset] = 666 }

        it 'does not initialize GovboxSet' do
          expect(GovboxSet).not_to receive(:new)

          described_class.new(search_params).run
        end
      end

      context 'when enable_highlighting is enabled' do
        subject(:search) { described_class.new(search_params) }

        before { search.run }

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'highlights title and description' do
          result = search.results.first
          expect(result.title).to match(/\ue000.+\ue001/)
          expect(result.description).to match(/\ue000.+\ue001/)
          expect(result.url).to match(URI.regexp)
        end

        it 'does not hightlight display_url' do
          expect(search.results.first.display_url).to_not match(/\ue000.+\ue001/)
        end

        its(:next_offset) { is_expected.to eq(20) }
        its(:modules) { is_expected.to include('BV5W') }
      end

      context 'when enable_highlighting is disabled' do
        subject(:search) do
          described_class.new(search_params.merge({enable_highlighting: false}))
        end

        before { search.run }

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'does not highlight the title and description' do
          result = search.results.first
          expect(result.title).to match(/agencies/i)
          expect(result.title).to_not match(/\ue000.+\ue001/)
          expect(result.description).to match(/agencies/i)
          expect(result.description).to_not match(/\ue000.+\ue001/)
        end

        its(:next_offset) { is_expected.to eq(20) }
        its(:modules) { is_expected.to include('BV5W') }
      end

      context 'when response _next is not present' do
        subject(:search) do
          described_class.new(search_params.merge({query: 'azure no next'}))
        end

        before do
          affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
          affiliate.excluded_domains.create!(domain: 'www.usa.gov')
          search.run
        end

        its(:next_offset) { is_expected.to be_nil }
      end

      context 'when the site locale is es' do
        let(:search) do
          described_class.new(search_params.merge( {query: 'educación'}))
        end

        before do
          allow(Language).to receive(:find_by_code).with('es').and_return(
            mock_model(Language, is_azure_supported: true, inferred_country_code: 'US')
          )
          affiliate.locale = 'es'
          search.run
        end

        it 'returns results' do
          expect(search.results.count).to eq(20)
        end

        it 'highlights title and description' do
          result = search.results[0]
          expect(result.title).to match(/\ue000.+\ue001/)
          expect(result.description).to match(/\ue000.+\ue001/)
        end

        it 'does not hightlight display_url' do
          expect(search.results.first.display_url).to_not match(/\ue000.+\ue001/)
        end
      end

      context 'when Azure response contains empty results' do
        subject(:search) do
          described_class.new(search_params.merge( {query: 'mango smoothie'}))
        end

        before { search.run }

        its(:results) { is_expected.to be_empty }
        its(:modules) { is_expected.not_to include('AWEB') }
      end
    end

    skip '#as_json' do
      subject(:search) do
        agency = Agency.create!({:name => 'Some New Agency', :abbreviation => 'SNA' })
        AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
        affiliate.stub(:agency).and_return(agency)

        described_class.new search_params
      end

      before { search.run }

      it 'returns results' do
        expect(search.as_json[:web][:results].count).to eq(20)
      end

      it 'highlights title and description' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.title).to match(/\ue000.+\ue001/)
        expect(result.snippet).to match(/\ue000.+\ue001/)
        expect(result.url).to match(URI.regexp)
      end

      it 'does not hightlight display_url' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.display_url).to_not match(/\ue000.+\ue001/)
      end

      it_should_behave_like 'an API search as_json'
      it_should_behave_like 'a commercial API search as_json'
    end
  end
end

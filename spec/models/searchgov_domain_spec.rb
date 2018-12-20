require 'spec_helper'

describe SearchgovDomain do
  let(:domain) { 'agency.gov' }
  subject(:searchgov_domain) { SearchgovDomain.new(domain: domain, scheme: 'http') }

  it { is_expected.to have_readonly_attribute(:domain) }

  describe 'schema' do
    it do
      is_expected.to have_db_column(:domain).of_type(:string).
        with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:clean_urls).of_type(:boolean).
        with_options(default: true, null: false)
    end

    it do
      is_expected.to have_db_column(:status).of_type(:string).
        with_options(null: true)
    end

    it do
      is_expected.to have_db_column(:urls_count).of_type(:integer).
        with_options(null: false, default: 0)
    end

    it do
      is_expected.to have_db_column(:unfetched_urls_count).of_type(:integer).
        with_options(null: false, default: 0)
    end

    it do
      is_expected.to have_db_column(:scheme).of_type(:string).
        with_options(null: false, default: 'http', limit: 5)
    end

    it do
      is_expected.to have_db_column(:activity).of_type(:string).
        with_options(null: false, default: 'idle', limit: 100)
    end

    it do
      is_expected.to have_db_column(:canonical_domain).of_type(:string).
        with_options(null: true)
    end

    describe 'indices' do
      it { is_expected.to have_db_index(:domain).unique(true) }
      it { is_expected.to have_db_index(:status) }
      it { is_expected.to have_db_index(:activity) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:searchgov_urls).dependent(:destroy) }
    it { is_expected.to have_many(:sitemaps).dependent(:destroy) }
  end

  describe 'validations' do
    it 'validates the domain format' do
      expect(SearchgovDomain.new(domain: 'foo')).not_to be_valid
      expect(SearchgovDomain.new(domain: 'search.gov')).to be_valid
    end

    it { is_expected.to validate_inclusion_of(:scheme).in_array %w(http https) }
    it { is_expected.to validate_uniqueness_of(:domain).case_insensitive.on(:create) }
  end

  describe 'lifecycle' do
    describe 'on create' do
      it 'downcases the domain' do
        expect(SearchgovDomain.create!(domain: 'AGENCY.GOV').domain).to eq 'agency.gov'
      end

      it 'removes whitespace' do
        expect(SearchgovDomain.create!(domain: ' agency.gov ').domain). to eq 'agency.gov'
      end
    end

    describe 'after create' do
      it 'enqueues a domain preparer job' do
        expect {
          SearchgovDomain.create!(domain: domain)
        }.to have_enqueued_job(SearchgovDomainPreparerJob)
      end
    end
  end

  describe 'scopes' do
    describe 'by status' do
      let!(:ok_domain) { SearchgovDomain.create!(domain: domain, status: '200 ok') }
      let!(:not_ok_domain) do
        SearchgovDomain.create!(domain: 'notok.gov', status: '403 Forbidden')
      end

      describe '.ok' do
        it 'includes domains returning 200' do
          expect(SearchgovDomain.ok).to match_array [ok_domain]
        end
      end

      describe '.not_ok' do
        it 'includes inaccessible domains' do
          expect(SearchgovDomain.not_ok).to match_array [not_ok_domain]
        end
      end
    end
  end

  describe 'counter columns' do
    let(:searchgov_domain) { SearchgovDomain.create(domain: domain) }

    describe '#urls_count' do
      it 'tracks the number of associated searchgov url records' do
        expect {
          searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov')
        }.to change{ searchgov_domain.reload.urls_count }.by(1)
      end
    end

    describe '#unfetched_urls_count' do
      it 'tracks the number of unfetched searchgov url records' do
        searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov/fetched', last_crawled_at: 1.day.ago)
        searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov/unfetched')
        expect(searchgov_domain.reload.unfetched_urls_count).to eq 1
      end
    end
  end

  describe '#delay' do
    subject(:delay) { searchgov_domain.delay }

    before do
      stub_request(:get, "http://#{domain}/robots.txt").
        to_return(status: [200, "OK"], headers: { content_type: 'text/plain' }, body: robots)
    end

    context 'when a delay is specified in robots.txt' do
      let(:robots) { "User-agent: *\nCrawl-delay: 10" }

      it { is_expected.to eq 10 }

      context 'when the domain is redirected' do
        before do
          stub_request(:get, "http://#{domain}/robots.txt").
            to_return(status: 301, headers: { location: "https://#{domain}/robots.txt" }, body: "")
          stub_request(:get, "https://#{domain}/robots.txt").
            to_return(status: [200, "OK"], headers: { content_type: 'text/plain' }, body: robots)
        end

        it { is_expected.to eq 10 }
      end
    end

    context 'when no delay is specified' do
      let(:robots) { "User-agent: *\nDisallow: /somedir/" }

      it 'defaults to 1' do
        expect(delay).to eq 1
      end
    end

    context 'when a delay is specified for the "usasearch" user agent' do
      let(:robots) { "User-agent: *\nCrawl-delay: 10\nUser-agent: usasearch\nCrawl-delay: 2" }

      # This needs to be fixed in the robotex gem:
      # https://github.com/chriskite/robotex/issues/9
      # https://www.pivotaltracker.com/story/show/157329443
      xit { is_expected.to eq 2 }
    end
  end

  describe '#index_urls' do
    subject(:index_urls) { searchgov_domain.index_urls }
    before do
      allow(searchgov_domain).to receive(:delay).and_return(5)
      allow(SearchgovDomainIndexerJob).to receive(:perform_later)
    end

    it 'enqueues a SearchgovDomainIndexerJob with the record & crawl-delay' do
      expect(SearchgovDomainIndexerJob).
        to receive(:perform_later).with(searchgov_domain: searchgov_domain, delay: 5)
      index_urls
    end

    it 'updates #activity as "indexing"' do
      expect { index_urls }.to change{ searchgov_domain.activity }.
        from('idle').to('indexing')
    end

    context 'when the domain is already being indexed' do
      let(:searchgov_domain) { SearchgovDomain.new(activity: 'indexing') }

      it 'does not enqueue another indexer job' do
        expect(SearchgovDomainIndexerJob).
          not_to receive(:perform_later)
        index_urls
      end

      it 'does not raise an error' do
        expect { index_urls }.not_to raise_error
      end

      it 'logs a message that the domain is being indexed' do
        expect(Rails.logger).to receive(:warn).with(/already being indexed/)
        index_urls
      end
    end
  end

  describe '#index_sitemaps' do
    subject(:index_sitemaps) { searchgov_domain.index_sitemaps }
    before do
      allow(searchgov_domain).to receive(:sitemap_urls).
        and_return ['http://agency.gov/sitemap.xml']
    end

    it 'indexes the sitemaps' do
      expect(SitemapIndexerJob).to receive(:perform_later).
        with(sitemap_url: 'http://agency.gov/sitemap.xml')
      index_sitemaps
    end
  end

  describe '#available?' do
    subject(:available) { searchgov_domain.available? }

    context 'when the status is null' do
      let(:searchgov_domain) { SearchgovDomain.new(domain: domain) }

      it 'checks the status' do
        expect(searchgov_domain).to receive(:check_status)
        available
      end
    end

    context 'when the status is 200' do
      let(:searchgov_domain) { SearchgovDomain.new(domain: domain, status: '200') }

      it { is_expected.to eq true }
    end

    context 'when the status indicates a problem' do
      let(:searchgov_domain) { SearchgovDomain.new(domain: domain, status: '403') }

      it { is_expected.to eq false }
    end
  end

  describe '#check_status' do
    let(:searchgov_domain) { SearchgovDomain.create!(domain: domain) }
    subject(:check_status) { searchgov_domain.check_status }

    context 'when the domain is available' do
      before { stub_request(:get, 'http://agency.gov').to_return(status: 200) }

      it 'sets the status to 200' do
        expect { check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('200 OK')
      end

      it 'returns the status' do
        expect(check_status).to eq '200 OK'
      end
    end

    context 'when the domain returns an error code' do
      before { stub_request(:get, 'http://agency.gov').to_return(status: [403, 'Forbidden']) }

      it 'sets the status to the error code'  do
       expect { check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('403 Forbidden')
      end
    end

    context 'when the request raises an error' do
      before do
        allow(searchgov_domain).to receive(:delay).and_return(0)
        stub_request(:get, 'http://agency.gov').to_raise(StandardError.new('kaboom'))
      end

      it 'sets the status to the error code'  do
        expect { check_status }.to raise_error(SearchgovDomain::DomainError, 'agency.gov: kaboom')
        expect(searchgov_domain.reload.status).to eq 'kaboom'
      end

      context 'when the error is transient' do
        before do
          stub_request(:get, 'http://agency.gov').to_raise(HTTP::ConnectionError).times(2).
            then.to_return(status: 200)
        end

        it 'retries the request' do
          expect(check_status).to eq '200 OK'
        end
      end
    end

    context 'when the domain is redirected' do
      before do
        stub_request(:get, "http://#{domain}").
          to_return(body: "", status: 301, headers: { 'Location' => new_url })
        stub_request(:get, new_url).to_return(status: 200)
      end

      context 'when the redirect is to https' do
        let(:new_url) { 'https://agency.gov/' }

        it 'sets the status to 200 OK' do
          expect { check_status }.to change{
            searchgov_domain.reload.status
          }.from(nil).to('200 OK')
        end

        it 'sets the scheme to "https"' do
          expect { check_status }.to change{
            searchgov_domain.reload.scheme
          }.from('http').to('https')
        end
      end

      context 'when the redirect is to another domain' do
        let(:new_url) { 'https://new.agency.gov' }

        it 'reports the canonical domain' do
          expect { check_status }.to change{
            searchgov_domain.reload.canonical_domain
          }.from(nil).to('new.agency.gov')
        end

        it 'sets the status to 200 OK' do
          expect { check_status }.to change{
            searchgov_domain.reload.status
          }.from(nil).to('200 OK')
        end
      end
    end
  end

  describe '#activity' do
    it 'defaults to "idle"' do
      expect(SearchgovDomain.new.activity).to eq 'idle'
    end

    describe '#index' do
      subject(:index) { searchgov_domain.index }

      it 'changes the activity to "indexing"' do
        expect { index }.to change{ searchgov_domain.activity }.
          from('idle').to('indexing')
      end
    end

    describe '#done_indexing' do
      let(:searchgov_domain) { SearchgovDomain.new(activity: 'indexing') }
      subject(:done_indexing) { searchgov_domain.done_indexing }

      it 'changes the activity to "idle"' do
        expect { done_indexing }.to change{ searchgov_domain.activity }.
          from('indexing').to('idle')
      end
    end
  end

  describe '#sitemap_urls' do
    subject(:sitemap_urls) { searchgov_domain.sitemap_urls }

    context 'when there is no robots.txt' do
      before do
        stub_request(:get, 'http://agency.gov/robots.txt').to_return(status: 404)
      end

      it { is_expected.to eq ['http://agency.gov/sitemap.xml'] }
    end

    context 'when the domain has a robots.txt file' do
      before do
        stub_request(:get, 'http://agency.gov/robots.txt').
          to_return(status: [200, 'OK'], body: robots_txt, headers: { content_type: 'text/plain' })
      end

      let(:robots_txt) { 'Sitemap: http://agency.gov/agency_sitemap.xml' }

      it { is_expected.to eq ['http://agency.gov/agency_sitemap.xml'] }

      context 'when no sitemap is listed on robots.txt' do
        let(:robots_txt) { 'Delay: 1' }

        it { is_expected.to eq ['http://agency.gov/sitemap.xml'] }
      end

      context 'when the sitemap entry is followed by a comment' do
        let(:robots_txt) { "Sitemap: http://agency.gov/commented.xml #comment" }

        it { is_expected.to eq ['http://agency.gov/commented.xml'] }
      end

      context 'when the sitemap url is relative' do
        let(:robots_txt) { 'Sitemap: /relative.xml' }

        it { is_expected.to eq ['http://agency.gov/relative.xml'] }
      end

      context 'when "sitemap" is lowercase' do
        let(:robots_txt) { 'sitemap: http://agency.gov/lower.xml' }

        it { is_expected.to eq ['http://agency.gov/lower.xml'] }
      end

      context 'when the sitemap is on another domain' do
        # This is technically permissible per the Sitemap protocol (https://www.sitemaps.org/protocol.html#location)
        # but so far we have only seen this done erroneously. To avoid indexing any undesired content,
        # we will ignore sitemaps on other domains.
        let(:robots_txt) { 'Sitemap: http://other.gov/agency_sitemap.xml' }

        it { is_expected.not_to include('http://other.gov/agency_sitemap.xml') }
      end

      context 'when the sitemap is listed with the wrong scheme' do
        let(:robots_txt) { 'Sitemap: https://agency.gov/https_sitemap.xml' }

        it { is_expected.to eq ['http://agency.gov/https_sitemap.xml'] }
      end

      context 'when the sitemap is listed twice' do
        let(:robots_txt) do
          <<~SITEMAP
            Sitemap: http://agency.gov/dupe_sitemap.xml
            Sitemap: http://agency.gov/dupe_sitemap.xml
          SITEMAP
        end

        it { is_expected.to eq ['http://agency.gov/dupe_sitemap.xml'] }
      end
    end

    context 'when the domain has sitemap records' do
      before do
        searchgov_domain.save!
        searchgov_domain.sitemaps.create!(url: 'http://agency.gov/sitemap_record.xml')
      end

      it { is_expected.to eq ['http://agency.gov/sitemap_record.xml'] }
    end
  end
end

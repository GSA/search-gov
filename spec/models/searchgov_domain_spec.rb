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

    it { is_expected.to have_db_index(:domain).unique(true) }

    it do
      is_expected.to have_db_column(:scheme).of_type(:string).
        with_options(null: false, default: 'http', limit: 5)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:searchgov_urls).dependent(:destroy) }
  end

  describe 'validations' do
    it 'validates the domain format' do
      expect(SearchgovDomain.new(domain: 'foo')).not_to be_valid
      expect(SearchgovDomain.new(domain: 'search.gov')).to be_valid
    end

    it { is_expected.to validate_inclusion_of(:scheme).in_array %w(http https) }
  end

  describe 'counter columns' do
    let(:searchgov_domain) { SearchgovDomain.create(domain: domain) }

    describe '#urls_count' do
      it 'tracks the number of associated searchgov url records' do
        expect{
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
    before { allow(searchgov_domain).to receive(:delay).and_return(5) }

    it 'enqueues a SearchgovDomainIndexerJob with the record & crawl-delay' do
      expect(SearchgovDomainIndexerJob).to receive(:perform_later).with(searchgov_domain, 5)
      searchgov_domain.index_urls
    end
  end

  describe '#index_sitemap' do
    subject(:index_sitemap) { searchgov_domain.index_sitemap }
    let(:indexer) { double(SitemapIndexer) }

    before do
      allow(searchgov_domain).to receive(:delay).and_return(5)
    end

    it 'indexes the sitemap' do
      expect(SitemapIndexer).to receive(:new).
        with(site: 'http://agency.gov/', delay: searchgov_domain.delay).
        and_return(indexer)
      expect(indexer).to receive(:index)
      index_sitemap
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
        expect{ check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('200 OK')
      end

      it 'returns the status' do
        expect(check_status).to eq '200 OK'
      end
    end

    context 'when the domain returns an error code' do
      before { stub_request(:get, 'http://agency.gov').to_return(status: [403, 'Forbidden']) }

      it 'sets the status to the error code'  do
       expect{ check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('403 Forbidden')
      end
    end

    context 'when the request raises an error' do
      before { stub_request(:get, 'http://agency.gov').to_raise(StandardError.new('kaboom')) }

      it 'sets the status to the error code'  do
        expect{ check_status }.to raise_error(StandardError)
        expect(searchgov_domain.reload.status).to eq 'kaboom'
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

        it 'sets the status to 200' do
          expect{ check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('200 OK')
        end

        it 'sets the scheme to "https"' do
          expect{ check_status }.to change{ searchgov_domain.reload.scheme }.from('http').to('https')
        end
      end

      context 'when the redirect is to another domain' do
        let(:new_url) { 'https://new.agency.gov' }

        it 'reports the canonical domain' do
          expect{ check_status }.to change{ searchgov_domain.reload.status }.
            from(nil).to('Canonical domain: new.agency.gov')
        end
      end
    end
  end
end

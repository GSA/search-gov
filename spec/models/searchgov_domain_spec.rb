require 'spec_helper'

describe SearchgovDomain do
  let(:domain) { 'agency.gov' }
  subject(:searchgov_domain) { SearchgovDomain.new(domain: domain) }

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
  end

  describe 'associations' do
    it { is_expected.to have_many(:searchgov_urls).dependent(:destroy) }
  end

  describe 'validations' do
    it 'validates the domain format' do
      expect(SearchgovDomain.new(domain: 'foo')).not_to be_valid
      expect(SearchgovDomain.new(domain: 'search.gov')).to be_valid
    end
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

  describe '#scheme'do
    subject(:scheme) { searchgov_domain.scheme }

    context 'when the host is secure' do
      before do
        stub_request(:get, "http://#{domain}/").
          to_return(status: 301, headers: { location: "https://#{domain}/" }, body: "")
        stub_request(:get, "https://#{domain}/").to_return(status: [200, "OK"])
      end

      it { is_expected.to eq 'https' }
    end

    context 'when the host is insecure' do
      before { stub_request(:get, "http://#{domain}/").to_return(status: [200, "OK"]) }

      it { is_expected.to eq 'http' }
    end

    context 'when something goes wrong' do
      before { stub_request(:get, "http://#{domain}/").to_return(status: [403]) }

      it 'updates the status and raises the error' do
        expect{ scheme }.to raise_error(/403/)
        expect(searchgov_domain.status).to eq '403'
      end
    end
  end

  describe '#index_sitemap' do
    subject(:index_sitemap) { searchgov_domain.index_sitemap }
    let(:indexer) { double(SitemapIndexer) }

    before do
      allow(searchgov_domain).to receive(:delay).and_return(5)
      allow(searchgov_domain).to receive(:scheme).and_return('http')
    end

    it 'indexes the sitemap' do
      expect(SitemapIndexer).to receive(:new).
        with(domain: domain, delay: searchgov_domain.delay, scheme: searchgov_domain.scheme).
        and_return(indexer)
      expect(indexer).to receive(:index)
      index_sitemap
    end
  end
end

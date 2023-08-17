# frozen_string_literal: true

require 'spec_helper'

describe SearchgovDomain do
  subject(:searchgov_domain) { described_class.new(domain: domain) }

  let(:domain) { 'searchgov.gov' }

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
      is_expected.to have_db_column(:activity).of_type(:string).
        with_options(null: false, default: 'idle', limit: 100)
    end

    it do
      is_expected.to have_db_column(:canonical_domain).of_type(:string).
        with_options(null: true)
    end

    it do
      is_expected.to have_db_column(:js_renderer).of_type(:boolean).
        with_options(default: false)
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
    it { is_expected.to validate_presence_of :domain }

    context 'when the domain is valid' do
      let(:valid_domains) { %w[fooo.gov foo.bar.gov foo.bar.baz.museum] }

      it 'is valid' do
        valid_domains.each do |domain|
          expect(described_class.new(domain: domain)).to be_valid
        end
      end
    end

    context 'when the domain is invalid' do
      let(:invalid_domains) { ['foo', 'foo.gov.', 'foo.gov/bar', 'foo.gov bar'] }

      it 'is invalid' do
        invalid_domains.each do |domain|
          expect(described_class.new(domain: domain)).not_to be_valid
        end
      end
    end

    it { is_expected.to validate_uniqueness_of(:domain).case_insensitive.on(:create) }
  end

  describe 'lifecycle' do
    describe 'on create' do
      it 'downcases the domain' do
        expect(described_class.create!(domain: 'SEARCHGOV.GOV').domain).to eq 'searchgov.gov'
      end

      it 'removes whitespace' do
        expect(described_class.create!(domain: ' searchgov.gov ').domain). to eq 'searchgov.gov'
      end
    end

    describe 'after create' do
      it 'enqueues a domain preparer job' do
        expect {
          described_class.create!(domain: domain)
        }.to have_enqueued_job(SearchgovDomainPreparerJob)
      end
    end
  end

  describe 'scopes' do
    describe 'by status' do
      let!(:ok_domain) { described_class.create!(domain: domain, status: '200 ok') }
      let!(:not_ok_domain) do
        described_class.create!(domain: 'notok.gov', status: '403 Forbidden')
      end
      let!(:nil_domain) do
        described_class.create!(domain: 'nil.gov', status: nil)
      end

      describe '.ok' do
        it 'includes domains returning 200' do
          expect(described_class.ok).to include ok_domain
        end

        it 'does not include inaccessible domains' do
          expect(described_class.ok).not_to include not_ok_domain
        end
      end

      describe '.not_ok' do
        it 'does not include domains returning 200' do
          expect(described_class.not_ok).not_to include ok_domain
        end

        it 'includes inaccessible domains' do
          expect(described_class.not_ok).to include not_ok_domain
        end

        it 'includes domains with nil status' do
          expect(described_class.not_ok).to include nil_domain
        end
      end
    end
  end

  describe 'counter columns' do
    let(:searchgov_domain) { described_class.create(domain: domain) }

    describe '#urls_count' do
      it 'tracks the number of associated searchgov url records' do
        expect {
          searchgov_domain.searchgov_urls.create!(url: 'https://searchgov.gov')
        }.to change{ searchgov_domain.reload.urls_count }.by(1)
      end
    end

    describe '#unfetched_urls_count' do
      it 'tracks the number of unfetched searchgov url records' do
        searchgov_domain.searchgov_urls.create!(url: 'https://searchgov.gov/fetched', last_crawled_at: 1.day.ago)
        searchgov_domain.searchgov_urls.create!(url: 'https://searchgov.gov/unfetched')
        expect(searchgov_domain.reload.unfetched_urls_count).to eq 1
      end
    end
  end

  describe '#delay' do
    subject(:delay) { searchgov_domain.delay }

    before do
      stub_request(:get, "https://#{domain}/robots.txt").
        to_return(status: [200, 'OK'], headers: { content_type: 'text/plain' }, body: robots)
    end

    context 'when a delay is specified in robots.txt' do
      let(:robots) { "User-agent: *\nCrawl-delay: 10" }

      it { is_expected.to eq 10 }

      context 'when the robots is redirected' do
        before do
          stub_request(:get, "https://#{domain}/robots.txt").
            to_return(status: 301, headers: { location: "https://#{domain}/other_robots.txt" }, body: '')
          stub_request(:get, "https://#{domain}/other_robots.txt").
            to_return(status: [200, 'OK'], headers: { content_type: 'text/plain' }, body: robots)
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

      it { is_expected.to eq 2 }
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
      let(:searchgov_domain) { described_class.new(activity: 'indexing') }

      it 'attempts to enqueue another indexer job' do
        expect(SearchgovDomainIndexerJob).to receive(:perform_later)
        index_urls
      end

      it 'does not raise an error' do
        expect { index_urls }.not_to raise_error
      end
    end
  end

  describe '#index_sitemaps' do
    subject(:index_sitemaps) { searchgov_domain.index_sitemaps }

    it 'indexes the sitemaps' do
      expect(SitemapIndexerJob).to receive(:perform_later).
        with(sitemap_url: 'https://searchgov.gov/sitemap.xml', domain: domain)
      index_sitemaps
    end
  end

  describe '#available?' do
    subject(:available) { searchgov_domain.available? }

    context 'when the status is null' do
      let(:searchgov_domain) { described_class.new(domain: domain) }

      it 'checks the status' do
        expect(searchgov_domain).to receive(:check_status)
        available
      end
    end

    context 'when the status is 200' do
      let(:searchgov_domain) { described_class.new(domain: domain, status: '200 OK') }

      it { is_expected.to eq true }
    end

    context 'when the status indicates a problem' do
      let(:searchgov_domain) { described_class.new(domain: domain, status: '403') }

      it { is_expected.to eq false }
    end
  end

  describe '#check_status' do
    subject(:check_status) { searchgov_domain.check_status }

    let(:searchgov_domain) { described_class.create!(domain: domain) }

    context 'when the domain is available' do
      before { stub_request(:get, 'https://searchgov.gov').to_return(status: 200) }

      it 'sets the status to 200' do
        expect { check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('200 OK')
      end

      it 'returns the status' do
        expect(check_status).to eq '200 OK'
      end
    end

    context 'when the domain returns an error code' do
      before { stub_request(:get, 'https://searchgov.gov').to_return(status: [403, 'Forbidden']) }

      it 'sets the status to the error code'  do
       expect { check_status }.to change{ searchgov_domain.reload.status }.from(nil).to('403 Forbidden')
      end
    end

    context 'when the domain is being indexed' do
      subject(:check_status_test) { searchgov_test_domain.check_status }

      let(:searchgov_test_domain) do
        described_class.create!(domain: 'test.gov', activity: 'indexing')
      end

      it "sets the state to 'idle'" do
        expect { check_status_test }.
          to change { searchgov_test_domain.reload.activity }.from('indexing').to('idle')
      end
    end

    context 'when the request raises an error' do
      before do
        allow(searchgov_domain).to receive(:delay).and_return(0)
        stub_request(:get, 'https://searchgov.gov').to_raise(StandardError.new('kaboom'))
      end

      it 'sets the status to the error code'  do
        expect { check_status }.not_to raise_error
        expect(searchgov_domain.reload.status).to eq 'kaboom'
      end

      it 'logs a message containing that error' do
        allow(Rails.logger).to receive(:error)
        check_status
        expect(Rails.logger).to have_received(:error).with(/kaboom/)
      end

      context 'when the error is transient' do
        before do
          stub_request(:get, 'https://searchgov.gov').to_raise(HTTP::ConnectionError).times(2).
            then.to_return(status: 200)
        end

        it 'retries the request' do
          expect(check_status).to eq '200 OK'
        end
      end
    end

    context 'when the domain is redirected' do
      before do
        stub_request(:get, "https://#{domain}").
          to_return(body: '', status: 301, headers: { 'Location' => new_url })
        stub_request(:get, new_url).to_return(status: 200)
      end

      context 'when the redirect is to another domain' do
        let(:new_url) { 'https://new.searchgov.gov' }

        it 'reports the canonical domain' do
          expect { check_status }.to change {
            searchgov_domain.reload.canonical_domain
          }.from(nil).to('new.searchgov.gov')
        end

        it 'sets the status to 200 OK' do
          expect { check_status }.to change {
            searchgov_domain.reload.status
          }.from(nil).to('200 OK')
        end
      end
    end
  end

  describe '#activity' do
    it 'defaults to "idle"' do
      expect(described_class.new.activity).to eq 'idle'
    end

    describe '#index' do
      subject(:index) { searchgov_domain.index }

      it 'changes the activity to "indexing"' do
        expect { index }.to change { searchgov_domain.activity }.
          from('idle').to('indexing')
      end
    end

    describe '#done_indexing' do
      subject(:done_indexing) { searchgov_domain.done_indexing }

      let(:searchgov_domain) { described_class.new(activity: 'indexing') }

      it 'changes the activity to "idle"' do
        expect { done_indexing }.to change { searchgov_domain.activity }.
          from('indexing').to('idle')
      end
    end
  end

  describe '#sitemap_urls' do
    subject(:sitemap_urls) { searchgov_domain.sitemap_urls }

    context 'when there is no robots.txt' do
      before do
        stub_request(:get, 'https://searchgov.gov/robots.txt').to_return(status: 404)
      end

      it { is_expected.to eq ['https://searchgov.gov/sitemap.xml'] }
    end

    context 'when the domain has a robots.txt file' do
      before do
        stub_request(:get, 'https://searchgov.gov/robots.txt').
          to_return(status: [200, 'OK'], body: robots_txt, headers: { content_type: 'text/plain' })
      end

      let(:robots_txt) { 'Sitemap: https://searchgov.gov/agency_sitemap.xml' }

      it { is_expected.to eq ['https://searchgov.gov/agency_sitemap.xml'] }

      context 'when no sitemap is listed on robots.txt' do
        let(:robots_txt) { 'Delay: 1' }

        it { is_expected.to eq ['https://searchgov.gov/sitemap.xml'] }
      end

      context 'when the sitemap entry is followed by a comment' do
        let(:robots_txt) { 'Sitemap: https://searchgov.gov/commented.xml #comment' }

        it { is_expected.to eq ['https://searchgov.gov/commented.xml'] }
      end

      context 'when the sitemap url is relative' do
        let(:robots_txt) { 'Sitemap: /relative.xml' }

        it { is_expected.to eq ['https://searchgov.gov/relative.xml'] }
      end

      context 'when "sitemap" is lowercase' do
        let(:robots_txt) { 'sitemap: https://searchgov.gov/lower.xml' }

        it { is_expected.to eq ['https://searchgov.gov/lower.xml'] }
      end

      context 'when the sitemap is on another domain' do
        # This is technically permissible per the Sitemap protocol
        # (https://www.sitemaps.org/protocol.html#location).
        let(:robots_txt) { 'Sitemap: https://other.gov/agency_sitemap.xml' }

        it { is_expected.to include('https://other.gov/agency_sitemap.xml') }
      end

      context 'when the sitemap is listed with the wrong scheme' do
        let(:robots_txt) { 'Sitemap: http://searchgov.gov/http_sitemap.xml' }

        it { is_expected.to eq ['https://searchgov.gov/http_sitemap.xml'] }
      end

      context 'when the sitemap is listed twice' do
        let(:robots_txt) do
          <<~SITEMAP
            Sitemap: https://searchgov.gov/dupe_sitemap.xml
            Sitemap: https://searchgov.gov/dupe_sitemap.xml
          SITEMAP
        end

        it { is_expected.to eq ['https://searchgov.gov/dupe_sitemap.xml'] }
      end
    end

    context 'when the domain has sitemap records' do
      before do
        searchgov_domain.save!
        searchgov_domain.sitemaps.create!(url: 'https://searchgov.gov/sitemap_record.xml')
      end

      it { is_expected.to eq ['https://searchgov.gov/sitemap_record.xml'] }
    end
  end
end

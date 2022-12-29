# frozen_string_literal: true

require 'spec_helper'

describe SitemapIndexer do
  let(:sitemap_url) { 'http://agency.gov/sitemap.xml' }
  let(:searchgov_domain) { searchgov_domains(:agency_gov) }
  let(:sitemap_entries) { '<url><loc>http://agency.gov/doc1</loc></url>' }
  let(:sitemap_content) do
    <<~SITEMAP
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
         #{sitemap_entries}
      </urlset>
    SITEMAP
  end
  let(:indexer) do
    described_class.new(
      sitemap_url: sitemap_url,
      domain: searchgov_domain.domain
    )
  end

  before do
    stub_request(:get, sitemap_url).
      with(headers: { 'User-Agent' => DEFAULT_USER_AGENT }).
      to_return(body: sitemap_content)
    allow_any_instance_of(SearchgovDomain).to receive_message_chain(:reload, :index_urls)
  end

  describe '#index' do
    subject(:index) { indexer.index }

    it 'creates searchgov urls' do
      expect { index }.to change { SearchgovUrl.count }.by(1)
    end

    context 'when the sitemap specifies a lastmod value' do
      let(:sitemap_entries) do
        '<url><loc>http://agency.gov/doc1</loc><lastmod>2018-01-01T12:00:00+00:00</lastmod></url>'
      end

      it 'sets the lastmod attribute' do
        index
        expect(SearchgovUrl.last.lastmod.to_s).to match(/^2018-01-01/)
      end
    end

    context 'when a sitemap url is a sitemap index' do
      let(:sitemap_content) do
        <<~SITEMAP_INDEX
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
             <sitemap>
                <loc>http://agency.gov/sitemap_a.xml</loc>
                <lastmod>2004-10-01T18:23:17+00:00</lastmod>
             </sitemap>
             <sitemap>
                <loc>http://agency.gov/sitemap_b.xml</loc>
                <lastmod>2005-01-01</lastmod>
             </sitemap>
          </sitemapindex>
        SITEMAP_INDEX
      end

      it 'enqueues new jobs to process both sitemaps' do
        index
        expect(SitemapIndexerJob).to have_been_enqueued.
          with(sitemap_url: 'http://agency.gov/sitemap_a.xml', domain: 'agency.gov')
        expect(SitemapIndexerJob).to have_been_enqueued.
          with(sitemap_url: 'http://agency.gov/sitemap_b.xml', domain: 'agency.gov')
      end
    end

    context 'when a searchgov url already exists' do
      let(:existing_url) do
        SearchgovUrl.create(url: 'http://agency.gov/doc1',
                            last_crawl_status: 'OK',
                            last_crawled_at: 1.week.ago)
      end

      context 'when lastmod is not specified in the sitemap' do
        let(:sitemap_entries) { '<url><loc>http://agency.gov/doc1</loc></url>' }

        it 'does not update the url' do
          expect { index }.not_to change { existing_url.reload.lastmod }
        end
      end

      context 'when when lastmod is specified in the sitemap' do
        let(:sitemap_entries) do
          '<url><loc>http://agency.gov/doc1</loc><lastmod>2021-01-01</lastmod></url>'
        end

        it 'updates the lastmod value' do
          expect { index }.to change { existing_url.reload.lastmod }.
            from(nil).to('2021-01-01'.to_time(:utc))
        end
      end
    end

    context 'when a SearchgovUrl record raises an error' do
      before do
        allow(SearchgovUrl).to receive(:find_or_initialize_by).and_raise(StandardError)
      end

      it 'rescues the error' do
        expect { indexer.index }.not_to raise_error
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(%r{"sitemap_entry_failed":"http://agency.gov/doc1"})
        indexer.index
      end
    end

    context 'when the sitemap contains whitespace around the elements' do
      let(:sitemap_entries) { "<url>\n  <loc>\n    http://agency.gov/doc1 \n    </loc>\n  </url>" }

      it 'creates a searchgov_url record' do
        expect { index }.to change { SearchgovUrl.count }.by(1)
      end
    end

    # This does not adhere to the Sitemaps protocol, but we're assuming
    # any scheme mismatches for our domain sitemaps are benign.
    context 'when the sitemap urls do not have the same scheme as the domain' do
      let(:sitemap_url) { 'https://agency.gov/sitemap.xml' }
      let(:sitemap_entries) { '<url><loc>http://agency.gov/doc1</loc></url>' }
      let(:site) { 'https://agency.gov' }

      it 'creates a SearchgovUrl record with the correct scheme' do
        index
        expect(SearchgovUrl.find_by(url: 'https://agency.gov/doc1')).not_to be_nil
      end
    end

    context 'when urls are from a different domain' do
      let(:sitemap_entries) do
        <<~SITEMAP_ENTRIES
          <url><loc>http://agency.gov/doc1</loc></url>
          <url><loc>http://www.agency.gov/doc1</loc></url>
          <url><loc>http://other.gov/doc1</loc></url>
        SITEMAP_ENTRIES
      end

      it 'ignores them' do
        index
        expect(SearchgovUrl.pluck(:url)).not_to include 'http://other.gov/doc1'
      end
    end

    it 'transitions to indexing the urls' do
      allow(SearchgovDomain).to receive(:find_by).
        with(domain: 'agency.gov').
        and_return(searchgov_domain)
      expect(searchgov_domain).to receive_message_chain(:reload, :index_urls)
      index
    end

    context 'when fetching the sitemap raises an error' do
      before do
        stub_request(:get, sitemap_url).to_raise(StandardError.new('kaboom'))
      end

      it 'does not raise an error' do
        expect { index }.not_to raise_error
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:warn).
          with(%r{"sitemap":"http://agency.gov/sitemap.xml","error":"kaboom"})
        index
      end
    end

    context 'when the XML is poorly formatted' do
      let(:sitemap_entries) do
        <<~SITEMAP_ENTRIES
          <url><loc>http://agency.gov/good</loc></url>'
          <url><loc>http://agency.gov/bad</loc></bad_tag>'
        SITEMAP_ENTRIES
      end

      it 'does not raise an error' do
        expect { index }.not_to raise_error
      end

      it 'processes as many entries as possible' do
        index
        expect(SearchgovUrl.find_by(url: 'http://agency.gov/good')).not_to be_nil
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Missing end tag for 'url'/)
        index
      end

      it 'kicks off indexing' do
        allow(SearchgovDomain).to receive(:find_by).
          with(domain: 'agency.gov').and_return(searchgov_domain)
        expect(searchgov_domain).to receive_message_chain(:reload, :index_urls)
        index
      end
    end

    context 'when a sitemap contains an invalid URL' do
      let(:sitemap_entries) { '<url><loc>http://agency.gov/doc (1).pdf</loc></url>' }

      it 'does not raise an error' do
        expect { indexer.index }.not_to raise_error
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Invalid URL/)
        index
      end
    end

    context 'when the sitemap is an rss 2.0 feed' do
      let(:searchgov_domain) { searchgov_domains(:www_whitehouse_gov) }
      let(:sitemap_content) { read_fixture_file('/rss/wh_blog.xml') }

      it 'creates searchgov_url records' do
        expect { index }.to change { SearchgovUrl.count }.by(3)
      end

      it 'extracts the lastmod timestamp for the rss items' do
        index
        expect(searchgov_domain.searchgov_urls.first.lastmod).
          to eq(Time.zone.parse('Mon, 26 Sep 2011 21:33:05 +0000'))
      end
    end
  end

  describe '#initialize' do
    context 'when given a sitemap url string having leading or trailing whitespace' do
      it 'strips the leading or trailing whitespace before parsing it' do
        expect(described_class.new(sitemap_url: " \n#{sitemap_url}\n ", domain: 'agency.gov').uri.to_s).to eq(sitemap_url)
      end
    end
  end
end

require 'spec_helper'

describe SitemapIndexer do
  let(:sitemap_url) { 'http://agency.gov/sitemap.xml' }
  let(:sitemap_entries) { '<url><loc>http://agency.gov/doc1</loc></url>' }
  let(:sitemap_content) do
    <<~SITEMAP
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
         #{sitemap_entries}
      </urlset>
    SITEMAP
  end
  let(:domain) { 'agency.gov' }
  let(:indexer) { SitemapIndexer.new(domain: domain, delay: 0) }

  before do
    stub_request(:get, sitemap_url).to_return(body: sitemap_content)
  end

  describe '#index' do
    subject(:index) { indexer.index }

    it 'creates searchgov urls' do
      expect{index}.to change{SearchgovUrl.count}.from(0).to(1)
    end

    it 'fetches the urls' do
      index
      expect(stub_request(:get, 'http://agency.gov/doc1')).to have_been_requested
    end

    context 'when the sitemap is listed in robots.txt' do
      let(:sitemap_url) { 'http://agency.gov/other.xml' }

      context 'when the sitemap entry is followed by a comment' do
        before do
          stub_request(:get, 'http://agency.gov/robots.txt').
            to_return(body: "Sitemap: #{sitemap_url} #important urls")
        end

        it 'fetches the sitemap' do
          index
          expect(stub_request(:get, 'http://agency.gov/other.xml')).to have_been_requested
        end
      end

      context 'when the sitemap url is relative' do
        before do
          stub_request(:get, 'http://agency.gov/robots.txt').
            to_return(body: "Sitemap: /relative.xml")
        end

        it 'fetches the sitemap' do
          index
          expect(stub_request(:get, 'http://agency.gov/relative.xml')).to have_been_requested
        end
      end

      context 'when "sitemap" is lowercase' do
        before do
          stub_request(:get, 'http://agency.gov/robots.txt').
            to_return(body: "sitemap: http://agency.gov/lower.xml")
        end

        it 'fetches the sitemap' do
          index
          expect(stub_request(:get, 'http://agency.gov/lower.xml')).to have_been_requested
        end
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
      let(:sitemap_a_content) do
        <<~SITEMAP
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
             <url><loc>http://agency.gov/doc1</loc></url>
          </urlset>
        SITEMAP
      end
      let(:sitemap_b_content) do
        <<~SITEMAP
          <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
             <url><loc>http://agency.gov/doc2</loc></url>
          </urlset>
        SITEMAP
      end

      before do
        stub_request(:get, 'http://agency.gov/sitemap_a.xml').to_return(body: sitemap_a_content)
        stub_request(:get, 'http://agency.gov/sitemap_b.xml').to_return(body: sitemap_b_content)
      end

      it 'fetches the urls in both sitemaps' do
        index
        expect(stub_request(:get, 'http://agency.gov/doc1')).to have_been_requested
        expect(stub_request(:get, 'http://agency.gov/doc2')).to have_been_requested
      end
    end

    context 'when a searchgov url already exists' do
      before do
        SearchgovUrl.create(url: 'http://agency.gov/doc1',
                            last_crawl_status: 'OK',
                            last_crawled_at: 1.week.ago)
      end

      context 'when lastmod is not specified in the sitemap' do
        let(:sitemap_entries) { '<url><loc>http://agency.gov/doc1</loc></url>' }

        it 'does not fetch the url' do
          index
          expect(stub_request(:get, 'http://agency.gov/doc1')).not_to have_been_requested
        end
      end

      context 'when the url was last modified before the last crawl' do
        let(:sitemap_entries) do
          "<url><loc>http://agency.gov/doc1</loc><lastmod>#{1.year.ago}</lastmod></url>"
        end

        it 'does not fetch the url' do
          index
          expect(stub_request(:get, 'http://agency.gov/doc1')).not_to have_been_requested
        end
      end

      context 'when the url was last modified after the last crawl' do
        let(:sitemap_entries) do
          "<url><loc>http://agency.gov/doc1</loc><lastmod>#{1.hour.ago}</lastmod></url>"
        end

        it 'fetches the url' do
          index
          expect(stub_request(:get, 'http://agency.gov/doc1')).to have_been_requested
        end
      end
    end
  end
end

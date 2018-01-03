require 'spec_helper'

describe SearchgovCrawler do
  let(:domain) { 'www.agency.gov' }
  let(:link) { "link1" }
  let(:url) { "https://#{domain}/#{link}" }
  let(:html) do
    <<~HTML
      <!DOCTYPE html>
      <html>
      <body>
      <a href="#{link}">link one</a>
      </body>
      </html>
    HTML
  end
  before do
    stub_request(:get, "https://#{domain}/").to_return(status: 200, body: html, headers: { content_type: 'text/html' })
  end

  describe '.perform' do
    subject(:perform) { SearchgovCrawler.perform(domain) }

    context 'when the crawl finds html links' do
      before do
        stub_request(:get, url).
          to_return(status: 200, body: "link 1", headers: { content_type: 'text/html' })
      end

      it 'creates searchgov urls' do
        perform
        expect(SearchgovUrl.pluck(:url)).to match_array(
          %w{ https://www.agency.gov/ https://www.agency.gov/link1 }
        )
      end
    end

    context 'when the crawl finds non-html links' do
      context 'when the content type is not supported' do
        before do
          stub_request(:get, url).
            to_return(status: 200, body: "link 1", headers: { content_type: 'not/html' })
        end

        it 'does not create searchgov urls' do
          perform
          expect(SearchgovUrl.pluck(:url)).to eq ['https://www.agency.gov/']
        end
      end

      context 'when the extension indicates a non-supported content type' do
        let(:link) { 'not_supported.mp3' }

        it 'does not attempt to fetch the page' do
          perform
          expect(stub_request(:get, url)).not_to have_been_requested
        end
      end

      context 'when the extension indicates an application document' do
        let(:link) { 'my_doc.pdf' }

        it 'does not attempt to fetch the page' do
          perform
          expect(stub_request(:get, url)).not_to have_been_requested
        end

        it 'creates a searchgov url' do
          perform
          expect(SearchgovUrl.pluck(:url)).to include('https://www.agency.gov/my_doc.pdf')
        end
      end

      context 'when the link is redirected' do
#stub_request(:get, rss_feed_url.url).to_return( body: "", status: 301, headers: { location: new_url } )
      end

      pending 'when the url already exists'
      pending 'it updates the last crawled status'
    end
  end
end

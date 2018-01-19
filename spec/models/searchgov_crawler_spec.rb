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

  describe '.crawl' do
    subject(:crawl) { SearchgovCrawler.crawl(domain: domain) }

    context 'when the crawl finds html links' do
      before do
        stub_request(:get, url).
          to_return(status: 200, body: "link 1", headers: { content_type: 'text/html' })
      end

      it 'creates searchgov urls' do
        crawl
        expect(SearchgovUrl.pluck(:url)).to match_array(
          %w{ https://www.agency.gov/ https://www.agency.gov/link1 }
        )
      end

      xit 'sets the crawl depth' do
        crawl
        expect(SearchgovUrl.find_by_url('https://www.agency.gov/').crawl_depth).to eq 0
        expect(SearchgovUrl.find_by_url(url).crawl_depth).to eq 1
      end
    end

    context 'when the crawl finds non-html links' do
      context 'when the content type is not supported' do
        before do
          stub_request(:get, url).
            to_return(status: 200, body: "link 1", headers: { content_type: 'not/html' })
        end

        it 'does not create searchgov urls' do
          crawl
          expect(SearchgovUrl.pluck(:url)).to eq ['https://www.agency.gov/']
        end
      end

      context 'when the extension indicates a non-supported content type' do
        let(:link) { 'not_supported.mp3' }

        it 'does not attempt to fetch the page' do
          crawl
          expect(stub_request(:get, url)).not_to have_been_requested
        end
      end

      context 'when the extension indicates an application document' do
        let(:link) { 'my_doc.pdf' }

        it 'does not attempt to fetch the page' do
          crawl
          expect(stub_request(:get, url)).not_to have_been_requested
        end

        it 'creates a searchgov url' do
          crawl
          expect(SearchgovUrl.pluck(:url)).to include('https://www.agency.gov/my_doc.pdf')
        end

        context 'when the url is disallowed by robots.txt' do
          let(:link) { 'admin/my_doc.pdf' }

          before do
            stub_request(:get, 'https://www.agency.gov/robots.txt').
              to_return(status: [200, 'OK'],
                        headers: { content_type: 'text/plain' },
                        body: "User-agent: *\nDisallow: /admin/")
          end

          it 'does not create a searchgov url' do
            crawl
            expect(SearchgovUrl.pluck(:url)).not_to include('https://www.agency.gov/admin/my_doc.pdf')
          end

          context 'when the robots.txt rule includes a comment' do
            let(:link) { 'admin/my_doc.pdf' }

            before do
              stub_request(:get, 'https://www.agency.gov/robots.txt').
                to_return(status: [200, 'OK'],
                          headers: { content_type: 'text/plain' },
                          body: "User-agent: *\nDisallow: /admin/ #ignore this")
            end

            it 'does not create a searchgov url' do
              crawl
              expect(SearchgovUrl.pluck(:url)).not_to include('https://www.agency.gov/admin/my_doc.pdf')
            end

          end
        end
      end

      context 'when the link is redirected' do
#stub_request(:get, rss_feed_url.url).to_return( body: "", status: 301, headers: { location: new_url } )
      end

      pending 'when the url already exists' do
        let!(:searchgov_url) { SearchgovUrl.create!(url: url) }

        it 'updates the depth and filetype' do
          expect{ crawl }.to change{ searchgov_url.filetype }.from(nil).to('html')
        end
      end

      pending 'it updates the last crawled status'
      pending 'it populates the depth & filetype'
      pending 'robots.txt - ensure application docs are skipped'
      pending 'when the same link is found at different crawl depths - only index lowest depth'
      pending 'it does not add pdf links with query strings when skip query strings is true' #https://www.treasurydirect.gov/exit.htm?http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=1996_register&docid=fr04oc96-24.pdf
      pending 'it does not create urls with noindex in the html metadata'

    end
  end
end

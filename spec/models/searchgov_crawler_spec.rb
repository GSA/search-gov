require 'spec_helper'

describe SearchgovCrawler do
  let(:options) do
    { domain: domain, srsly: true }
  end
  let(:crawler) { SearchgovCrawler.new(options) }
  let(:domain) { 'www.agency.gov' }
  let(:base_url) { "http://www.agency.gov/" }
  let(:link) { "link1" }
  let(:url) { "http://#{domain}/#{link}" }
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
    stub_request(:get, base_url).
      to_return(status: 200, body: html, headers: { content_type: 'text/html' })
  end

  describe '.crawl' do
    subject(:crawl) { crawler.crawl }

    before do
      allow(SearchgovUrl).to receive(:create).with(url: base_url)
    end

    context 'when the home page uses a client-side redirect' do #because that's a thing.
      before do
        stub_request(:get, base_url).
          to_return(status: [200, 'OK'],
                    body: '<html><meta http-equiv="refresh" content="0; url=/index.shtml"></html>')

      end

      it 'sets the site as the url indicated by the redirection' do
        Medusa.should_receive(:crawl).with('http://www.agency.gov/index.shtml', anything)
        crawl
      end
    end

    describe 'options' do
      describe 'crawl delay' do
        context 'when a crawl delay is specified in robots.txt' do
          before do
            stub_request(:get, 'http://www.agency.gov/robots.txt').
              to_return(status: [200, 'OK'],
                        headers: { content_type: 'text/plain' },
                        body: "User-agent: *\nCrawl-delay: 10")
          end

          it 'sets the specified delay' do
            Medusa.should_receive(:crawl).
              with('http://www.agency.gov/',hash_including(delay: 10))
            crawl
          end
        end

        context 'when a crawl delay is specified in the arguments' do
          let(:crawler) { SearchgovCrawler.new(options.merge(delay: 3)) }

          it 'sets the specified delay' do
            Medusa.should_receive(:crawl).
              with('http://www.agency.gov/',hash_including(delay: 3))
            crawl
          end
        end
      end
    end

    context 'when the crawl finds html links' do
      before do
        stub_request(:get, url).
          to_return(status: 200, body: "link 1", headers: { content_type: 'text/html' })
        allow(SearchgovUrl).to receive(:create).with(url: base_url)
      end

      it 'creates searchgov urls' do
        expect(SearchgovUrl).to receive(:create).with(url: 'http://www.agency.gov/')
        expect(SearchgovUrl).to receive(:create).with(url: 'http://www.agency.gov/link1')
        crawl
      end

      context 'when srsly is false' do
        let(:options) { { domain: domain, srsly: false  } }

        it 'does not create searchgov urls' do
          expect(SearchgovUrl).not_to receive(:create)
          crawl
        end

        describe '#url_file' do
          it 'contains the crawled links' do
            crawl
            expect(open(crawler.url_file).read).
              to eq "url,depth\nhttp://www.agency.gov/,0\nhttp://www.agency.gov/link1,1\n"
          end
        end
      end

      context 'when the url is disallowed by robots.txt' do
        let(:link) { 'admin/page1' }

        before do
          stub_request(:get, 'http://www.agency.gov/robots.txt').
            to_return(status: [200, 'OK'],
                      headers: { content_type: 'text/plain' },
                      body: "User-agent: *\nDisallow: /admin/")
        end

        it 'does not create a searchgov url' do
          crawl
          expect(SearchgovUrl.pluck(:url)).not_to include(url)
        end

        context 'when the robots.txt rule includes a comment' do
          before do
            stub_request(:get, 'http://www.agency.gov/robots.txt').
              to_return(status: [200, 'OK'],
                        headers: { content_type: 'text/plain' },
                        body: "User-agent: *\nDisallow: /admin/ #ignore this")
          end

          it 'does not create a searchgov url' do
            crawl
            expect(SearchgovUrl.pluck(:url)).not_to include(url)
          end
        end
      end

      context 'when the crawler hits a snag' do
        before do
          expect(crawler).to receive(:indexable?).with(anything()).at_least(1).times.and_raise('boom')
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(/Error crawling/).at_least(1).times
          crawl
        end

        it 'suceeds' do
          expect{ crawl }.not_to raise_error
        end
      end

      context 'when the link includes an anchor' do
        let(:link) { '/anchor#An Anchor!' }

        before do
          stub_request(:get, 'http://www.agency.gov/anchor').
            to_return(status: 200, body: "page with anchors", headers: { content_type: 'text/html' })
        end

        it 'strips the anchor fragment' do
          expect(SearchgovUrl).to receive(:create).with(url: "#{base_url}anchor")
          crawl
        end
      end

      context 'when the link includes trailing spaces' do
        let(:link) { '/extra_space' }

        before do
          stub_request(:get, 'http://www.agency.gov/extra_space').
            to_return(status: 200, body: "page with an extra space", headers: { content_type: 'text/html' })
        end

        it 'strips the anchor fragment' do
          expect(SearchgovUrl).to receive(:create).with(url: "#{base_url}extra_space")
          crawl
        end
      end

      context 'when the link is a potential crawler trap' do
        context 'when the link contains any segment repeated 3 or more times' do
          let(:link) { 'foo/baz/foo/biz/foo/qux/' }

          it 'does not attempt to fetch that link' do
            crawl
            expect(stub_request(:get, url)).not_to have_been_requested
          end
        end
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
          expect(SearchgovUrl).not_to receive(:create).with(url: url)
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
          allow(SearchgovUrl).to receive(:create).with(url: 'http://www.agency.gov/my_doc.pdf')
          crawl
          expect(stub_request(:get, url)).not_to have_been_requested
        end

        it 'creates a searchgov url' do
          expect(SearchgovUrl).to receive(:create).with(url: 'http://www.agency.gov/my_doc.pdf')
          crawl
        end

        context 'when srsly is false' do
          let(:options) { { domain: domain, srsly: false  } }

          describe '#url_file' do
            it 'contains the crawled links' do
              crawl
              expect(open(crawler.url_file).read).
                to eq "url,depth\nhttp://www.agency.gov/,0\nhttp://www.agency.gov/my_doc.pdf,1\n"
            end
          end
        end

        context 'when the url is disallowed by robots.txt' do
          let(:link) { 'admin/my_doc.pdf' }

          before do
            stub_request(:get, 'http://www.agency.gov/robots.txt').
              to_return(status: [200, 'OK'],
                        headers: { content_type: 'text/plain' },
                        body: "User-agent: *\nDisallow: /admin/")
          end

          it 'does not create a searchgov url' do
            crawl
            expect(SearchgovUrl.pluck(:url)).not_to include('http://www.agency.gov/admin/my_doc.pdf')
          end

          context 'when the robots.txt rule includes a comment' do
            let(:link) { 'admin/my_doc.pdf' }

            before do
              stub_request(:get, 'http://www.agency.gov/robots.txt').
                to_return(status: [200, 'OK'],
                          headers: { content_type: 'text/plain' },
                          body: "User-agent: *\nDisallow: /admin/ #ignore this")
            end

            it 'does not create a searchgov url' do
              crawl
              expect(SearchgovUrl.pluck(:url)).not_to include('http://www.agency.gov/admin/my_doc.pdf')
            end
          end

          context 'when the doc link contains a query string' do
            let(:link) { 'admin/foo?bar.pdf' }
            it 'does not create a searchgov url' do
              expect(SearchgovUrl).not_to receive(:create).with(url: url)
              crawl
            end
          end
        end
      end

      context 'when the link is redirected' do
        let(:new_url) { 'http://www.agency.gov/new' }

        before do
          stub_request(:get, url).to_return(body: "", status: 301,
            headers: { location: new_url })
          stub_request(:get, new_url).to_return(body: "new", status: 200,
            headers: { content_type: 'text/html' })
        end

        it 'creates a searchgov url for the new location' do
          allow(SearchgovUrl).to receive(:create).with(url: base_url)
          expect(SearchgovUrl).to receive(:create).with(url: new_url)
          crawl
        end
      end

      context 'when the link is temporarily redirected' do
        before do
          stub_request(:get, url).to_return(body: "", status: 302,
            headers: { location: new_url, content_type: 'text/html' })
          stub_request(:get, new_url).to_return(body: "new", status: 200,
            headers: { content_type: 'text/html' })
        end

        context 'to an external domain' do
          let(:new_url) { 'http://www.external.gov/external' }

          it "doesn't log the redirected link" do
            allow(SearchgovUrl).to receive(:create).with(url: url)
            expect(SearchgovUrl).not_to receive(:create).with(url: new_url)
            crawl
          end
        end
      end
    end
  end

  # Testing this private method directly for test speed
  describe '.repeating_segments_regex' do
    subject(:regex) { crawler.send(:repeating_segments_regex) }

    it { is_expected.to match 'http://www.agency.gov/foo/foo/foo/' }
    it { is_expected.to match 'http://www.agency.gov/foo/baz/foo/biz/foo/qux/' }
    it { is_expected.not_to match 'http://www.agency.gov/fee/fie/foe/' }
    it { is_expected.not_to match 'http://www.agency.gov/foo/foo/' }
    it { is_expected.not_to match 'http://www.agency.gov/f/foo/foo' }
    it { is_expected.not_to match 'http://www.agency.gov/foofoofoo/' }
    it { is_expected.not_to match 'http://www.agency.gov/09/09/09/' }
  end
end

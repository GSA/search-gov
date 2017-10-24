require 'spec_helper'

describe SearchgovUrl do
  let(:url) { 'http://www.agency.gov/boring.html' }
  let(:html) { read_fixture_file("/html/page_with_metadata.html") }
  let(:valid_attributes) { { url: url } }

  let(:searchgov_url) { SearchgovUrl.new(valid_attributes) }
  let(:i14y_document) { I14yDocument.new }

  describe 'schema' do
    it { should have_db_column(:url).of_type(:string).
         with_options(null: false, limit: 2000) }
    it { should have_db_column(:last_crawl_status).of_type(:string) }
    it { should have_db_column(:last_crawled_at).of_type(:datetime) }
    it { should have_db_column(:load_time).of_type(:integer) }

    it { should have_db_index(:url).unique }
  end

  describe 'validations' do
    describe 'validating url uniqueness' do
      let!(:existing) { SearchgovUrl.create!(valid_attributes) }
      it "validates url uniqueness" do
        duplicate = SearchgovUrl.new(url: existing.url)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:url].first).to match(/already been taken/)
      end

      it 'validates url uniqueness without protocol' do
        duplicate = SearchgovUrl.new(url: 'https://www.agency.gov/boring.html')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:url].first).to match(/already been taken/)
      end
    end

    describe "normalizing URLs when saving" do
      context "when URL doesn't have a protocol" do
        let(:url) { "www.nps.gov/sdfsdf" }

        it "should prepend it with https://" do
          SearchgovUrl.create!(url: url).url.should == "https://www.nps.gov/sdfsdf"
        end
      end

      context 'when the url contains query parameters' do
        let(:url) { 'http://www.irs.gov/foo?bar=baz' }

        it 'omits the query parameters' do
          expect{ searchgov_url.valid? }.
            to change{ searchgov_url.url }.from(url).to('http://www.irs.gov/foo')
        end
      end
    end
  end

  describe '#fetch' do
    context 'when the fetch is successful' do
      let(:success_hash) do
        { status: 200, body: html, headers: { content_type: "text/html" } }
      end
      before do
        stub_request(:get, url).with(headers: { user_agent: 'usasearch' }).
          to_return({ status: 200, body: html, headers: { content_type: "text/html" } })
        stub_request(:get, url).with(headers: { 'User-Agent' => 'usasearch' }).
          to_return(success_hash)
        searchgov_url.save!
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            document_id: 'www.agency.gov/boring.html',
            handle: 'searchgov',
            path: url,
            title: 'My Title',
            description: 'My description',
            language: 'en',
            tags: 'this, that',
        ))
        searchgov_url.fetch
      end

      context 'when the document is successfully indexed' do
        before do
          I14yDocument.stub(:create).with(anything).and_return(i14y_document)
        end

        it 'records the load time' do
          expect{ searchgov_url.fetch }.
            to change{ searchgov_url.reload.load_time.class }
            .from(NilClass).to(Fixnum)
        end

        it 'records the success status' do
          expect{ searchgov_url.fetch }.
            to change{ searchgov_url.reload.last_crawl_status }
            .from(NilClass).to('OK')

        end

        it 'records the last crawl time' do
          expect{ searchgov_url.fetch }.
            to change{ searchgov_url.reload.last_crawled_at }
            .from(NilClass).to(Time)
        end
      end

      context 'when the indexing fails' do
        before { I14yDocument.stub(:create).and_raise(StandardError.new('Kaboom')) }

        it 'records the error' do
          expect{ searchgov_url.fetch }.not_to raise_error
          expect(searchgov_url.last_crawl_status).to match(/Kaboom/)
        end
      end

      context 'when the fetch successfully returns...an error page' do #Because that's a thing.
        let(:fail_html) do
          "<html><head><title>My 404 error page</title></head><body>Epic fail!</body></html>"
        end
        before do
          stub_request(:get, url).
            to_return({ status: 200,
                        body: fail_html,
                        headers: { content_type: "text/html" } })
        end

        it 'reports the 404' do
          searchgov_url.fetch
          expect(searchgov_url.last_crawl_status).to eq '404'
        end
      end

      context 'when the page should not be indexed' do
        before do
          expect(I14yDocument).not_to receive(:create)
        end

        context 'when noindex is specified in the page' do
          let(:html) do
            '<html><head><title>foo</title><META NAME="ROBOTS" CONTENT="NOINDEX"></head></html>'
          end

          it 'records the error' do
            searchgov_url.fetch
            expect(searchgov_url.last_crawl_status).to eq 'Noindex per HTML metadata'
          end
        end

        context 'when noindex is specified in the header' do
          before do
            stub_request(:get, url).
              to_return({ status: 200, headers: { 'X-Robots-Tag' => 'noindex,nofollow' } })
          end

          it 'records the error' do
            searchgov_url.fetch
            expect(searchgov_url.last_crawl_status).to eq 'Noindex per X-Robots-Tag header'
          end
        end
      end
    end

    context 'when the url points to a pdf' do
      let(:url) { 'https://www.irs.gov/test.pdf' }
      let(:pdf) { read_fixture_file("/pdf/test.pdf") }
      before do
        stub_request(:get, url).
          to_return({ status: 200,
                      body: pdf,
                      headers: { content_type: "application/pdf" } })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            handle: 'searchgov',
            path: url,
            title: 'My Title',
            description: 'My description',
            language: 'en',
            tags: 'this, that',
            created: '2017-09-07T23:26:04Z',
        ))
        searchgov_url.fetch
      end
    end

    context 'when the url points to a Word doc (.doc)' do
      let(:url) { 'https://www.irs.gov/test.doc' }
      let(:doc) { read_fixture_file("/word/test.doc") }
      before do
        stub_request(:get, url).
          to_return({ status: 200,
                      body: doc,
                      headers: { content_type: "application/msword" } })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            handle: 'searchgov',
            path: url,
            title: 'My Word Doc',
            description: 'My Word doc description',
            language: 'en',
            tags: 'word',
        ))
        searchgov_url.fetch
      end
    end

    context 'when the url points to a Word doc (.docx)' do
      let(:url) { 'https://www.irs.gov/test.docx' }
      let(:doc) { read_fixture_file("/word/test.docx") }
      before do
        stub_request(:get, url).
          to_return({ status: 200,
                      body: doc,
                      headers: { content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' } })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            handle: 'searchgov',
            path: url,
            title: 'My Word Doc',
            description: 'My Word doc description',
            language: 'en',
            tags: 'word',
        ))
        searchgov_url.fetch
      end
    end

    context 'when the url points to an Excel doc (.xlsx)' do
      let(:url) { 'https://www.irs.gov/test.xlsx' }
      let(:doc) { read_fixture_file("/excel/test.xlsx") }
      before do
        stub_request(:get, url).
          to_return({ status: 200,
                      body: doc,
                      headers: { content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' } })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            handle: 'searchgov',
            path: url,
            title: 'My Excel Doc',
            description: 'My Excel doc description',
            language: 'en',
            tags: 'excel',
        ))
        searchgov_url.fetch
      end
    end

    context 'when the url points to an Excel doc (.xls)' do
      let(:url) { 'https://www.irs.gov/test.xls' }
      let(:doc) { read_fixture_file("/excel/test.xls") }
      before do
        stub_request(:get, url).
          to_return({ status: 200,
                      body: doc,
                      headers: { content_type: 'application/vnd.ms-excel' } })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            handle: 'searchgov',
            path: url,
            title: 'My Excel Doc',
            description: 'My Excel doc description',
            language: 'en',
            tags: 'excel',
        ))
        searchgov_url.fetch
      end
    end

    context 'when the fetch fails' do
      context 'when the request fails' do
        before { stub_request(:get, url).to_raise(StandardError.new('faaaaail')) }

        it 'records the error' do
          expect{ searchgov_url.fetch }.not_to raise_error
          expect(searchgov_url.last_crawl_status).to match(/faaaaail/)
        end
      end
    end

    context 'when the url is redirected' do
      let(:new_url) { 'https://www.agency.gov/boring.html' }

      before do
        allow(I14yDocument).to receive(:create).
          with(hash_including(title: 'My Title', description: 'My description' ))
        stub_request(:get, url).
          to_return({ status: 301, body: html, headers: { location: new_url } })
        stub_request(:get, new_url).
          to_return({ status: 200, body: html, headers: { content_type: 'text/html' } })
      end

      it 'saves the correct url' do
        expect{ searchgov_url.fetch }.
          to change{searchgov_url.url}.from(url).to(new_url)
      end

      context 'when it is redirected to a url outside the original domain' do
        let(:new_url) { 'http://www.random.com/boring.html' }

        it 'disallows the redirect' do
          searchgov_url.fetch
          expect(searchgov_url.last_crawl_status).to match(/Redirection forbidden to/)
        end

        it 'does not index the content' do
          expect(I14yDocument).not_to receive(:create)
          searchgov_url.fetch
        end
      end
    end

    context 'when the content type is unsupported' do
      before do
        stub_request(:get, url).
          to_return({ status: 200, headers: { content_type: 'foo/bar' } })
        searchgov_url.save!
      end

      it 'reports the error' do
        searchgov_url.fetch
        expect(searchgov_url.last_crawl_status).to eq "Unsupported content type 'foo/bar'"
      end
    end
  end

  it_should_behave_like 'a record with a fetchable url'
end

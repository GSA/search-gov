require 'spec_helper'

describe SearchgovUrl do
  let(:url) { 'http://www.agency.gov/boring.html' }
  let(:html) { read_fixture_file("/html/page_with_metadata.html") }
  let(:valid_attributes) { { url: url } }
  let(:searchgov_url) { SearchgovUrl.new(valid_attributes) }
  let(:i14y_document) { I14yDocument.new }

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it { is_expected.to have_db_column(:url).of_type(:string).
         with_options(null: false, limit: 2000) }
    it { is_expected.to have_db_column(:last_crawl_status).of_type(:string) }
    it { is_expected.to have_db_column(:last_crawled_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:load_time).of_type(:integer) }

    it { is_expected.to have_db_index(:url) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_domain) }

    context 'on creation' do
      context 'when the domain already exists' do
        let!(:existing_domain) { SearchgovDomain.create!(domain: 'existing.gov') }

        it 'sets the searchgov domain' do
          searchgov_url = SearchgovUrl.create!(url: 'https://existing.gov/foo')
          expect(searchgov_url.searchgov_domain).to eq existing_domain
        end
      end

      context 'when the domain has not been created yet' do
        it 'creates the domain' do
          expect{ SearchgovUrl.create!(url: 'https://brand_new.gov/foo') }.
            to change{ SearchgovDomain.count }.by(1)
        end
      end
    end
  end

  describe 'validations' do
    it 'requires a valid domain' do
      searchgov_url = SearchgovUrl.new(url: 'https://foo/bar')
      expect(searchgov_url).not_to be_valid
      expect(searchgov_url.errors.messages[:searchgov_domain]).to include 'is invalid'
    end

    describe 'validating url uniqueness' do
      let!(:existing) { SearchgovUrl.create!(valid_attributes) }

      it { is_expected.to validate_uniqueness_of(:url).on(:create) }

      it 'is case-sensitive' do
        expect(SearchgovUrl.new(url: 'https://www.agency.gov/BORING.html')).to be_valid
      end
    end

    describe "normalizing URLs when saving" do
      context "when URL doesn't have a protocol" do
        let(:url) { "www.nps.gov/sdfsdf" }

        it "should prepend it with https://" do
          expect(SearchgovUrl.create!(url: url).url).to eq("https://www.nps.gov/sdfsdf")
        end
      end

      context 'when the url contains query parameters' do
        let(:url) { 'http://www.irs.gov/foo?bar=baz' }

        it 'retains the query parameters' do
          expect{ searchgov_url.valid? }.not_to change{ searchgov_url.url }
        end
      end

      context 'when the url requires escaping' do
        let(:url) { "https://www.foo.gov/my_url’s_weird!" }

        it 'escapes the url' do
          expect{ searchgov_url.valid? }.
            to change{ searchgov_url.url }.from(url).to("https://www.foo.gov/my_url%E2%80%99s_weird!")
        end

        context 'when the url is already escaped' do
          let(:url) { "https://www.foo.gov/my_url%E2%80%99s_weird!" }

          it 'does not re-escape the url' do
            expect{ searchgov_url.valid? }.not_to change{ searchgov_url.url }
          end
        end
      end
    end
  end

  describe 'callbacks' do
    context 'when destroying' do
      it 'deletes the document' do
        expect(I14yDocument).to receive(:delete).
          with(handle: 'searchgov', document_id: searchgov_url.document_id)
        searchgov_url.destroy
      end

      context 'when the document cannot be deleted' do
        let!(:searchgov_url) { SearchgovUrl.create!(valid_attributes) }

        before do
          allow(I14yDocument).to receive(:delete).
            with(handle: 'searchgov', document_id: searchgov_url.document_id).
            and_raise(I14yDocument::I14yDocumentError.new('not found'))
        end

        it 'deletes the Searchgov Url' do
          expect{ searchgov_url.destroy }.to change{ SearchgovUrl.count }.from(1).to(0)
        end
      end
    end
  end

  describe '#document_id' do
    it 'returns the hashed url' do
      expect(searchgov_url.document_id).to eq "1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef"
    end
  end

  describe '#fetch' do
    context 'when the fetch is successful' do
      let(:success_hash) do
        { status: 200, body: html, headers: { content_type: "text/html" } }
      end
      before do
        stub_request(:get, url).with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return({ status: 200, body: html, headers: { content_type: "text/html" } })
        stub_request(:get, url).with(headers: { 'User-Agent' => DEFAULT_USER_AGENT }).
          to_return(success_hash)
        searchgov_url.save!
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
            document_id: '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef',
            handle: 'searchgov',
            path: url,
            title: 'My Title',
            description: 'My description',
            language: 'en',
            tags: 'this, that',
        ))
        searchgov_url.fetch
      end

      context 'when the document has already been indexed' do
        before { allow(searchgov_url).to receive(:indexed?).and_return(true) }

        it 'updates the document' do
          expect(I14yDocument).to receive(:update).
            with(hash_including(
              document_id: '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef',
              handle: 'searchgov',
              path: url,
              title: 'My Title',
              description: 'My description',
              language: 'en',
              tags: 'this, that',
          ))
          searchgov_url.fetch
        end
      end

      context 'when the document is successfully indexed' do
        before do
          allow(I14yDocument).to receive(:create).with(anything).and_return(i14y_document)
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
        before { allow(I14yDocument).to receive(:create).and_raise(StandardError.new('Kaboom')) }

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

        context 'when the file is too large' do
          before do
            stub_request(:get, url).to_return(status: 200, headers: {  content_type: "application/pdf",
                                                                       content_length:  11.megabytes })
          end

          it 'reports the error' do
            searchgov_url.fetch
            expect(searchgov_url.last_crawl_status).to eq "Document is over 10 MB limit"
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

    context 'when the request fails' do
      before { stub_request(:get, url).to_raise(StandardError.new('faaaaail')) }

      it 'records the error' do
        expect{ searchgov_url.fetch }.not_to raise_error
        expect(searchgov_url.last_crawl_status).to match(/faaaaail/)
      end

      context 'when the url had previously been indexed' do
        before { searchgov_url.stub(:indexed?).and_return(true) }

        it 'deletes the document' do
          expect(I14yDocument).to receive(:delete).
            with(handle: 'searchgov', document_id: searchgov_url.document_id)
          searchgov_url.fetch
        end
      end
    end

    context 'when the url is redirected' do
      let(:new_url) { 'https://www.agency.gov/new.html' }

      before do
        expect(I14yDocument).not_to receive(:create).
          with(hash_including(title: 'My Title', description: 'My description' ))
        stub_request(:get, url).
          to_return({ status: 301, body: html, headers: { location: new_url } })
        stub_request(:get, new_url).
          to_return({ status: 200, body: html, headers: { content_type: 'text/html' } })
      end

      it 'creates a url' do
        expect(SearchgovUrl).to receive(:create).with(url: new_url)
        searchgov_url.fetch
      end

      context 'when it is redirected to a url outside the original domain' do
        let(:new_url) { 'http://www.random.com/' }

        it 'disallows the redirect' do
          searchgov_url.fetch
          expect(searchgov_url.last_crawl_status).to match(/Redirection forbidden to/)
        end

        it 'does not index the content' do
          expect(I14yDocument).not_to receive(:create)
          searchgov_url.fetch
        end

        it 'does not create a new url' do
          expect(SearchgovUrl).not_to receive(:create).with(url: new_url)
          searchgov_url.fetch
        end
      end
    end

    context 'when the redirect requires a cookie' do
      let(:url) { 'https://www.medicare.gov/find-a-plan/questions/home.aspx' }

      it 'can index the content' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(title: 'Medicare Plan Finder for Health, Prescription Drug and Medigap plans'))
        searchgov_url.fetch
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

  describe '.fetch_new' do
    subject(:fetch_new) { SearchgovUrl.fetch_new(delay: 0) }

    context 'when a redirection results in a new record being created' do
      let(:url) { 'http://agency.gov/old' }
      let(:new_url) { 'http://agency.gov/new' }

      before do
        SearchgovUrl.create!(url: url)
        stub_request(:get, url).to_return(status: 301, headers: { location: new_url })
        stub_request(:get, new_url).
          to_return(status: 200, body: html, headers: { content_type: 'text/html' })
        allow_any_instance_of(SearchgovUrl).to receive(:index_document).and_return(true)
      end

      it 'fetches both urls' do
        fetch_new
        expect(SearchgovUrl.fetched.pluck(:url)).
          to match_array %w[http://agency.gov/old http://agency.gov/new]
      end

      context 'when something goes wrong' do
        before do
          allow_any_instance_of(SearchgovUrl).to receive(:save!).and_raise(StandardError)
        end

        it 'rescues and logs the error' do
          expect(Rails.logger).to receive(:error).with(/Unable to index/).at_least(:once)
          fetch_new
        end
      end
    end
  end

  describe '#last_crawl_status' do
    context 'when an error message is very long' do
      before { stub_request(:get, url).to_raise(StandardError.new('x' * 256)) }

      it 'truncates too-long crawl statuses' do
        expect{ searchgov_url.fetch }.not_to raise_error
        expect(searchgov_url.last_crawl_status).to eq 'x' * 255
      end
    end
  end

  it_should_behave_like 'a record with a fetchable url'
end

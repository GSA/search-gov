# frozen_string_literal: true

require 'spec_helper'

describe SearchgovUrl do
  let(:url) { 'https://www.agency.gov/boring.html' }
  let(:html) { read_fixture_file('/html/page_with_og_metadata.html') }
  let(:valid_attributes) { { url: url } }
  let(:searchgov_url) { described_class.new(valid_attributes) }

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it {
      is_expected.to have_db_column(:url).of_type(:string).
        with_options(null: false, limit: 2000)
    }

    it { is_expected.to have_db_column(:load_time).of_type(:integer) }
    it { is_expected.to have_db_column(:lastmod).of_type(:datetime) }
    it { is_expected.to have_db_column(:hashed_url).of_type(:string).with_options(limit: 64) }

    it {
      is_expected.to have_db_column(:enqueued_for_reindex).
        of_type(:boolean).
        with_options(default: false, null: false)
    }

    it { is_expected.to have_db_index(:last_crawl_status) }
    it { is_expected.to have_db_index(:url) }
    it { is_expected.to have_db_index([:searchgov_domain_id, :last_crawl_status]) }
    it { is_expected.to have_db_index([:searchgov_domain_id, :last_crawled_at]) }
    it { is_expected.to have_db_index([:searchgov_domain_id, :enqueued_for_reindex]) }
  end

  describe 'scopes' do
    describe '.fetch_required' do
      it 'includes urls that have never been crawled and outdated urls' do
        expect(described_class.fetch_required.pluck(:url)).
          to include('https://www.agency.gov/new', 'https://www.agency.gov/outdated')
      end

      it 'does not include current, crawled and not enqueued urls' do
        expect(described_class.fetch_required.pluck(:url)).
          not_to include('https://www.agency.gov/current')
      end

      it 'includes urls that have been enqueued for reindexing' do
        expect(described_class.fetch_required.pluck(:url)).
          to include 'https://www.agency.gov/enqueued'
      end

      it 'includes urls last crawled more than 30 days and crawl status is ok' do
        expect(described_class.fetch_required.pluck(:url)).
          to include 'https://www.agency.gov/crawled_more_than_month'
      end
    end
  end

  describe 'validations' do
    let(:searchgov_url) { described_class.new(valid_attributes) }

    context 'when the URL domain does not already exist in our database' do
      let(:url) { 'https://new-agency.com/index.html' }

      it { is_expected.not_to be_valid }

      it 'generates a helpful error message' do
        searchgov_url.valid?
        expect(searchgov_url.errors.messages[:searchgov_domain]).
          to include 'is not a valid SearchgovDomain'
      end
    end

    describe 'validating url uniqueness' do
      it { is_expected.to validate_uniqueness_of(:url).on(:create) }

      it 'is case-sensitive' do
        expect(described_class.new(url: 'https://www.agency.gov/BORING.html')).to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_one(:searchgov_document).dependent(:destroy) }
  end

  describe 'callbacks' do
    describe 'on create' do
      it 'sets the hashed_url' do
        searchgov_url = described_class.create!(valid_attributes)
        expect(searchgov_url.hashed_url).to eq(
          '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef'
        )
      end
    end

    context 'when destroying' do
      it 'deletes the document' do
        expect(I14yDocument).to receive(:delete).
          with(handle: 'searchgov', document_id: searchgov_url.document_id)
        searchgov_url.destroy
      end

      context 'when the document cannot be deleted' do
        let!(:searchgov_url) { described_class.create!(valid_attributes) }

        before do
          allow(I14yDocument).to receive(:delete).
            with(handle: 'searchgov', document_id: searchgov_url.document_id).
            and_raise(I14yDocument::I14yDocumentError.new('not found'))
        end

        it 'deletes the Searchgov Url' do
          expect { searchgov_url.destroy }.to change { described_class.count }.by(-1)
        end
      end
    end
  end

  describe '#document_id' do
    it 'returns the hashed url' do
      expect(searchgov_url.document_id).to eq '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef'
    end
  end

  describe '#fetch' do
    subject(:fetch) { searchgov_url.fetch }

    let!(:searchgov_url) { described_class.create!(valid_attributes) }
    let(:searchgov_domain) do
      instance_double(SearchgovDomain, check_status: '200 OK', available?: true, js_renderer: false)
    end
    let(:searchgov_document) { searchgov_url.searchgov_document }

    before do
      allow(searchgov_url).to receive(:searchgov_domain).and_return(searchgov_domain)
      allow(I14yDocument).to receive(:create)
    end

    context 'when the fetch is successful' do
      before do
        stub_request(:get, url).with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: html,
                    headers: { content_type: 'text/html',
                               etag: '123' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 document_id: '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef',
                 handle: 'searchgov',
                 path: url,
                 title: 'My OG Title',
                 description: 'My OG Description',
                 content: "This is my headline.\nThis is my content.",
                 content_type: 'video.movie',
                 thumbnail_url: 'http://www.foo.gov/og_image.jpg',
                 language: 'en',
                 tags: 'this, that, the other, thing',
                 created: '2015-07-02T10:12:32-04:00',
                 changed: '2017-03-30T13:18:28-04:00',
                 mime_type: 'text/html'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged off' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'false'
        end

        it 'does not save a document to searchgov_documents' do
          expect { fetch }.not_to change { SearchgovDocument.count }
        end
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        context 'when no searchgov_document exists' do
          it 'saves the document to searchgov_documents' do
            expect { fetch }.to change { SearchgovDocument.count }.
              from(0).to(1)
          end

          it 'saves html content in searchgov_documents' do
            fetch
            expect(searchgov_document.web_document).to include('<p>This is my content.</p>')
          end
        end

        context 'when a searchgov_document with the same searchgov_url_id and entity tag exists' do
          before do
            SearchgovDocument.create!(
              web_document: 'An existing body',
              headers: { etag: '123' },
              searchgov_url_id: searchgov_url.id
            )
          end

          it 'does not save a new document to searchgov_documents' do
            expect { fetch }.not_to change { SearchgovDocument.count }
          end

          it 'does not update the existing document' do
            expect { fetch }.not_to change { searchgov_document.updated_at }
          end
        end

        context 'when a searchgov_document with the same searchgov_url_id but a different entity tag exists' do
          before do
            SearchgovDocument.create!(
              web_document: 'An existing body',
              headers: { etag: '456' },
              searchgov_url_id: searchgov_url.id
            )
          end

          it 'does not save a new document to searchgov_documents' do
            expect { fetch }.not_to change { SearchgovDocument.count }
          end

          it 'updates the existing document' do
            expect { fetch }.to change { searchgov_document.updated_at }
          end
        end

        context 'when the record is enqueued for reindex' do
          let(:searchgov_url) do
            described_class.create!(valid_attributes.merge(enqueued_for_reindex: true))
          end

          it 'sets enqueued_for_reindex to false' do
            expect { fetch }.to change { searchgov_url.enqueued_for_reindex }.
              from(true).to(false)
          end
        end

        context 'when the record includes a lastmod value' do
          let(:valid_attributes) { { url: url, lastmod: '2018-01-01' } }

          it 'passes that as the changed value' do
            expect(I14yDocument).to receive(:create).
              with(hash_including(changed: '2018-01-01T00:00:00Z'))
            fetch
          end

          context 'when the document includes a modified value' do
            before do
              allow_any_instance_of(HtmlDocument).
                to receive(:modified).and_return('2018-03-30T01:00:00-04:00')
            end

            let(:valid_attributes) { { url: url, lastmod: '2018-01-01' } }

            it 'passes whichever value is more recent' do
              expect(I14yDocument).to receive(:create).
                with(hash_including(changed: '2018-01-01T00:00:00Z'))
              fetch
            end
          end
        end

        context 'when the document has already been indexed' do
          before { allow(searchgov_url).to receive(:indexed?).and_return(true) }

          it 'updates the document' do
            expect(I14yDocument).to receive(:update).
              with(hash_including(
                     document_id: '1ff7dfd3cf763d08bee3546e2538cf0315578fbd7b1d3f28f014915983d4d7ef',
                     handle: 'searchgov',
                     path: url,
                     title: 'My OG Title',
                     description: 'My OG Description',
                     content: "This is my headline.\nThis is my content.",
                     language: 'en',
                     tags: 'this, that, the other, thing',
                     created: '2015-07-02T10:12:32-04:00',
                     changed: '2017-03-30T13:18:28-04:00'
              ))
            fetch
          end
        end

        context 'when the document is successfully indexed' do
          before do
            allow(I14yDocument).to receive(:create).with(anything).and_return(I14yDocument.new)
          end

          it 'records the load time' do
            expect { fetch }.
              to change { searchgov_url.reload.load_time.class }.
              from(NilClass).to(Integer)
          end

          it 'records the success status' do
            expect { fetch }.
              to change { searchgov_url.reload.last_crawl_status }.
              from(NilClass).to('OK')
          end

          it 'records the last crawl time' do
            expect { fetch }.
              to change { searchgov_url.reload.last_crawled_at }.
              from(NilClass).to(Time)
          end
        end

        context 'when the indexing fails' do
          before { allow(I14yDocument).to receive(:create).and_raise(StandardError.new('Kaboom')) }

          it 'records the error' do
            expect { fetch }.not_to raise_error
            expect(searchgov_url.last_crawl_status).to match(/Kaboom/)
          end
        end

        context 'when the fetch successfully returns...an error page' do # Because that's a thing.
          before do
            fail_html = '<html><head><title>My 404 error page</title></head><body>Epic fail!</body></html>'
            stub_request(:get, url).
              to_return(status: 200,
                        body: fail_html,
                        headers: { content_type: 'text/html' })
          end

          it 'reports the 404' do
            fetch
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
              fetch
              expect(searchgov_url.last_crawl_status).to eq 'Noindex per HTML metadata'
            end
          end

          context 'when noindex is specified in the header' do
            before do
              stub_request(:get, url).
                to_return(status: 200,
                          headers: { 'X-Robots-Tag' => 'noindex,nofollow' })
            end

            it 'records the error' do
              fetch
              expect(searchgov_url.last_crawl_status).to eq 'Noindex per X-Robots-Tag header'
            end
          end

          context 'when the file is too large' do
            before do
              stub_request(:get, url).to_return(status: 200,
                                                headers: { content_type: 'application/pdf',
                                                           content_length: 18.megabytes })
            end

            it 'reports the error' do
              fetch
              expect(searchgov_url.last_crawl_status).to eq 'Document is over 15 MB limit'
            end
          end
        end

        describe 'setting the last_crawl_status' do
          context 'when an error message is very long' do
            before do
              allow(searchgov_url).to receive(:index_document).and_raise(StandardError.new('x' * 256))
            end

            it 'truncates too-long crawl statuses' do
              expect { fetch }.not_to raise_error
              expect(searchgov_url.last_crawl_status).to eq 'x' * 255
            end
          end
        end
      end
    end

    context 'when the searchgov domain has js renderer enabled' do
      before do
        allow(searchgov_url).to receive(:searchgov_domain).and_return(domain_with_js_renderer)
        allow(JsFetcher).to receive(:fetch)
      end

      let(:url) { 'https://search.gov/javascript-test.html' }
      let(:domain_with_js_renderer) do
        instance_double(SearchgovDomain, check_status: '200 OK', available?: true, js_renderer: true)
      end

      it 'fetches page with javascript fetcher' do
        fetch
        expect(JsFetcher).to have_received(:fetch).with(url)
      end
    end

    context 'when the searchgov domain has js renderer disabled' do
      before do
        allow(searchgov_url).to receive(:searchgov_domain).and_return(domain_without_js_renderer)
        allow(JsFetcher).to receive(:fetch)
      end

      let(:url) { 'https://search.gov/javascript-test.html' }
      let(:domain_without_js_renderer) do
        instance_double(SearchgovDomain, check_status: '200 OK', available?: true, js_renderer: false)
      end

      it 'fetches page without javascript fetcher' do
        fetch
        expect(JsFetcher).not_to have_received(:fetch).with(url)
      end
    end

    context 'when the url points to a pdf' do
      let(:url) { 'https://agency.gov/test.pdf' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: read_fixture_file('/pdf/test.pdf'),
                    headers: { content_type: 'application/pdf',
                               etag: '123' })
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
                 created: '2018-06-09T17:42:11Z'
          ))
        fetch
      end

      it 'removes downloaded files' do
        expect_any_instance_of(Tempfile).to receive(:close!)
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves pdf content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is a test PDF file')
        end

        it 'saves pdf metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['dcterms:created']).to eq('2018-06-09T17:42:11Z')
        end

        context 'when a searchgov_document application document was parsed by the current version of tika' do
          before do
            SearchgovDocument.create!(
              web_document: 'An existing body',
              headers: { etag: '123' },
              tika_version: 2.4,
              searchgov_url_id: searchgov_url.id
            )
          end

          it 'does not save a new document to searchgov_documents' do
            expect { fetch }.not_to change { SearchgovDocument.count }
          end

          it 'does not update the existing document' do
            expect { fetch }.not_to change { searchgov_document.updated_at }
          end
        end

        context 'when a searchgov_document application document was parsed by an older version of tika' do
          before do
            SearchgovDocument.create!(
              web_document: 'An existing body',
              headers: { content_type: 'text/html' },
              tika_version: 0.0,
              searchgov_url_id: searchgov_url.id
            )
          end

          it 'does not save a new document to searchgov_documents' do
            expect { fetch }.not_to change { SearchgovDocument.count }
          end

          it 'updates the existing document' do
            expect { fetch }.to change { searchgov_document.updated_at }
          end
        end
      end
    end

    context 'when the url points to a Word doc (.doc)' do
      let(:url) { 'https://agency.gov/test.doc' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: read_fixture_file('/word/test.doc'),
                    headers: { content_type: 'application/msword' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 handle: 'searchgov',
                 path: url,
                 title: 'My Word Doc',
                 description: 'My Word doc description',
                 language: 'en',
                 tags: 'word'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves .doc content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is a Word Doc.')
        end

        it 'saves .doc metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['dcterms:created']).to eq('2017-09-26T23:17:27Z')
        end
      end
    end

    context 'when the url points to a Word doc (.docx)' do
      let(:url) { 'https://agency.gov/test.docx' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: read_fixture_file('/word/test.docx'),
                    headers: { content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 handle: 'searchgov',
                 path: url,
                 title: 'My Word Doc',
                 description: 'My Word doc description',
                 language: 'en',
                 tags: 'word'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves .docx content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is a Word Doc.')
        end

        it 'saves .docx metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['dcterms:created']).to eq('2017-09-26T15:17:27Z')
        end
      end
    end

    context 'when the url points to an Excel doc (.xlsx)' do
      let(:url) { 'https://agency.gov/test.xlsx' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: read_fixture_file('/excel/test.xlsx'),
                    headers: { content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 handle: 'searchgov',
                 path: url,
                 title: 'My Excel Doc',
                 description: 'My Excel doc description',
                 language: 'en',
                 tags: 'excel'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves .xlsx content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is an Excel doc.')
        end

        it 'saves .xlsx metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['dcterms:created']).to eq('2017-10-05T11:24:38Z')
        end
      end
    end

    context 'when the url points to an Excel doc (.xls)' do
      let(:url) { 'https://agency.gov/test.xls' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: read_fixture_file('/excel/test.xls'),
                    headers: { content_type: 'application/vnd.ms-excel' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 handle: 'searchgov',
                 path: url,
                 title: 'My Excel Doc',
                 description: 'My Excel doc description',
                 language: 'en',
                 tags: 'excel'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves .xls content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is an Excel doc.')
        end

        it 'saves .xls metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['dcterms:created']).to eq('2017-10-05T19:24:38Z')
        end
      end
    end

    context 'when the url points to a TXT doc (.txt)' do
      let(:url) { 'https://agency.gov/test.txt' }

      before do
        stub_request(:get, url).
          with(headers: { user_agent: DEFAULT_USER_AGENT }).
          to_return(status: 200,
                    body: 'This is my text content.',
                    headers: { content_type: 'text/plain' })
      end

      it 'fetches and indexes the document' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(
                 handle: 'searchgov',
                 path: 'https://agency.gov/test.txt',
                 title: 'test.txt',
                 description: nil,
                 content: 'This is my text content.',
                 language: 'en'
          ))
        fetch
      end

      context 'when searchgov_document save functionality is flagged on' do
        before do
          ENV['SAVE_SEARCHGOV_DOCUMENT'] = 'true'
        end

        it 'saves .txt content in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['X-TIKA:content']).to include('This is my text content.')
        end

        it 'saves .txt metadata in searchgov_documents' do
          fetch
          parsed_body = JSON.parse searchgov_document.web_document.gsub('=>', ':')
          expect(parsed_body['Content-Encoding']).to eq('ISO-8859-1')
        end
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:get, url).to_raise(StandardError.new('faaaaail'))
      end

      it 'records the error' do
        expect { fetch }.not_to raise_error
        expect(searchgov_url.last_crawl_status).to match(/faaaaail/)
      end

      context 'when the url had previously been indexed' do
        before { searchgov_url.stub(:indexed?).and_return(true) }

        it 'deletes the document' do
          expect(I14yDocument).to receive(:delete).
            with(handle: 'searchgov', document_id: searchgov_url.document_id)
          fetch
        end

        context 'when the document cannot be deleted' do
          before do
            allow(I14yDocument).to receive(:delete).and_raise('something went wrong')
            allow(Rails.logger).to receive(:error)
          end

          it 'logs the error' do
            fetch
            expect(Rails.logger).to have_received(:error).with(
              /Unable to delete Searchgov i14y document.*something went wrong/
            )
          end
        end
      end

      it 'checks the domain status' do
        expect(searchgov_domain).to receive(:check_status)
        fetch
      end
    end

    context 'when the url is redirected' do
      let(:new_url) { 'https://www.agency.gov/new.html' }

      before do
        expect(I14yDocument).not_to receive(:create).
          with(hash_including(title: 'My Title', description: 'My description'))
        stub_request(:get, url).
          to_return(status: 301,
                    body: html,
                    headers: { location: new_url })
        stub_request(:get, new_url).
          to_return(status: 200,
                    body: html,
                    headers: { content_type: 'text/html' })
      end

      it 'creates a url' do
        expect(described_class).to receive(:create).with(url: new_url)
        fetch
      end

      it 'reports the redirect' do
        expect { fetch }.to change { searchgov_url.last_crawl_status }.
          from(nil).to('Redirected to https://www.agency.gov/new.html')
      end

      context 'when it is redirected to a url outside the original domain' do
        let(:new_url) { 'https://www.random.com/' }

        it 'disallows the redirect' do
          fetch
          expect(searchgov_url.last_crawl_status).to match(/Redirection forbidden to/)
        end

        it 'does not index the content' do
          expect(I14yDocument).not_to receive(:create)
          fetch
        end

        it 'does not create a new url' do
          expect(described_class).not_to receive(:create).with(url: new_url)
          fetch
        end
      end

      context 'when on the client side' do
        let(:html) do
          "<header><meta http-equiv=\"refresh\" content=\"0; URL='/client_side.html'\"/></header>"
        end

        before do
          stub_request(:get, url).
            to_return(status: 200,
                      body: html,
                      headers: { content_type: 'text/html' })
        end

        it 'creates a url' do
          expect(described_class).to receive(:create).
            with(url: 'https://www.agency.gov/client_side.html')
          fetch
        end
      end
    end

    context 'when the redirect requires a cookie' do
      let(:url) { 'https://www.medicare.gov/find-a-plan/questions/home.aspx' }

      it 'can index the content' do
        expect(I14yDocument).to receive(:create).
          with(hash_including(title: 'Medicare Plan Finder for Health, Prescription Drug and Medigap plans'))
        fetch
      end
    end

    context 'when the content type is unsupported' do
      before do
        stub_request(:get, url).
          to_return(status: 200,
                    headers: { content_type: 'foo/bar' })
      end

      it 'reports the error' do
        fetch
        expect(searchgov_url.last_crawl_status).to eq "Unsupported content type 'foo/bar'"
      end
    end

    context 'when the response is a 403' do
      before { stub_request(:get, url).to_return(status: 403) }

      it 'checks the domain status' do
        expect(searchgov_domain).to receive(:check_status)
        fetch
      end

      context 'when the url has already been indexed' do
        before { allow(searchgov_url).to receive(:indexed?).and_return(true) }

        context 'when the domain is unavailable' do
          let!(:searchgov_domain) { searchgov_url.searchgov_domain }

          before do
            stub_request(:get, 'https://www.agency.gov/').to_return(status: 403)
            searchgov_domain.update!(status: '200 OK')
          end

          it 'does not delete the document' do
            expect(searchgov_url).not_to receive(:delete_document)
            fetch
          end
        end
      end
    end

    context 'when the domain is unavailable' do
      let(:unavailable_domain) do
        instance_double(
          SearchgovDomain, domain: 'unavailable.gov', available?: false, status: '403'
        )
      end

      before do
        allow(searchgov_url).to receive(:searchgov_domain).and_return(unavailable_domain)
      end

      it 'raises an error, including the domain' do
        expect { fetch }.to raise_error(described_class::DomainError, 'unavailable.gov: 403')
      end

      it 'does not fetch the url' do
        expect { fetch }.to raise_error(described_class::DomainError, 'unavailable.gov: 403')
        expect(stub_request(:get, url)).not_to have_been_requested
      end
    end
  end

  it_behaves_like 'a record with a fetchable url'
  it_behaves_like 'a record with an indexable url'
  it_behaves_like 'a record that belongs to a searchgov_domain'
  it_behaves_like 'a record that requires https'
end

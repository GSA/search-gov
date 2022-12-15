# frozen_string_literal: true

describe BulkUrlUploader do
  let(:raw_urls) { [] }
  let(:urls) { StringIO.new(raw_urls.join("\n")) }
  let(:uploader) { described_class.new('the-uploader', urls) }

  describe '#upload_and_index' do
    context 'with two good URls' do
      let(:raw_urls) do
        [
          'https://agency.gov/a-url',
          'https://agency.gov/another-url'
        ]
      end

      before { uploader.upload_and_index }

      it 'creates the first SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: raw_urls.first)).not_to be_nil
      end

      it 'creates the second SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: raw_urls.second)).not_to be_nil
      end

      it 'reports the number of URLs processed' do
        expect(uploader.results.total_count).to eq(raw_urls.length)
      end

      it 'reports the number of URLs created' do
        expect(uploader.results.ok_count).to eq(raw_urls.length)
      end

      it 'reports the number of errors' do
        expect(uploader.results.error_count).to eq(0)
      end

      it 'does not report any errors' do
        expect(uploader.results.error_messages).to be_empty
      end
    end

    context 'when reindexing URLs' do
      let(:uploader) { described_class.new('uploader', urls, reindex: true) }
      let(:raw_urls) do
        [
          'https://agency.gov/new',
          'https://agency.gov/existing'
        ]
      end

      before do
        SearchgovUrl.create!(url: 'https://agency.gov/existing')
        uploader.upload_and_index
      end

      it 'creates new URLs' do
        expect(SearchgovUrl.exists?(url: 'https://agency.gov/new')).to be true
      end

      it 'enqueues existing urls to be reindexed' do
        searchgov_url = SearchgovUrl.find_by(url: 'https://agency.gov/existing')
        expect(searchgov_url.enqueued_for_reindex).to be true
      end

      it 'does not enqueue new URLs' do
        searchgov_url = SearchgovUrl.find_by(url: 'https://agency.gov/new')
        expect(searchgov_url.enqueued_for_reindex).to be false
      end
    end

    describe 'with a URL that is for a bad domain' do
      let(:raw_urls) { ['https://bad-agency.gov/a-url'] }

      before { uploader.upload_and_index }

      it 'does not create the SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: raw_urls.first)).to be(nil)
      end

      it 'reports the number of URLs processed' do
        expect(uploader.results.total_count).to eq(raw_urls.length)
      end

      it 'reports the number of URLs created' do
        expect(uploader.results.ok_count).to eq(0)
      end

      it 'reports the number of errors' do
        expect(uploader.results.error_count).to eq(raw_urls.length)
      end

      it 'reports the error' do
        expect(uploader.results.error_messages.length).to eq(raw_urls.length)
      end

      it 'reports the url with the error' do
        error = uploader.results.error_messages.first
        urls_with_error = uploader.results.urls_with(error)
        expect(urls_with_error).to eq(raw_urls)
      end
    end
  end
end

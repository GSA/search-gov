
describe 'BulkUrlUploader' do
  let(:urls) { [] }
  let(:url_file) { StringIO.new(urls.join("\n")) }
  let(:the_uploader) { BulkUrlUploader.new('the-uploader', url_file) }

  describe '#upload_and_index' do
    before { the_uploader.upload_and_index }

    describe 'happy path with two good URls' do
      let(:urls) do
        [
          "https://agency.gov/a-url",
          "https://agency.gov/another-url"
        ]
      end

      it 'creates the first SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: urls.first)).not_to be(nil)
      end

      it 'creates the second SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: urls.second)).not_to be(nil)
      end

      it 'reports the number of URLs processed' do
        expect(the_uploader.results.total_count).to eq(urls.length)
      end

      it 'reports the number of URLs created' do
        expect(the_uploader.results.ok_count).to eq(urls.length)
      end

      it 'reports the number of errors' do
        expect(the_uploader.results.error_count).to eq(0)
      end

      it 'does not report any errors' do
        expect(the_uploader.results.error_messages).to be_empty
      end
    end

    describe 'with a URL that is for a bad domain' do
      let(:urls) { [ "https://bad-agency.gov/a-url" ] }

      it 'does not create the SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: urls.first)).to be(nil)
      end

      it 'reports the number of URLs processed' do
        expect(the_uploader.results.total_count).to eq(urls.length)
      end

      it 'reports the number of URLs created' do
        expect(the_uploader.results.ok_count).to eq(0)
      end

      it 'reports the number of errors' do
        expect(the_uploader.results.error_count).to eq(urls.length)
      end

      it 'reports the error' do
        expect(the_uploader.results.error_messages.length).to eq(urls.length)
      end

      it 'reports the url with the error' do
        expect(the_uploader.results.urls_with(the_uploader.results.error_messages.first)).to eq(urls)
      end
    end
  end
end

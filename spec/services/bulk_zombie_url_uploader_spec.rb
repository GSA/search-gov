# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:raw_urls) { [] }
  let(:urls) { StringIO.new(raw_urls.join("\n")) }
  let(:uploader) { described_class.new('the-uploader', urls) }

  describe '#upload' do
    context 'with two good URls' do
      let(:raw_urls) do
        [
          'https://agency.gov/a-url',
          'https://agency.gov/another-url'
        ]
      end

      before { uploader.upload }

      it 'deletes the first SearchgovUrl' do
        expect(SearchgovUrl.find_by(url: raw_urls.first)).not_to be_nil
      end

      it 'deletes the second SearchgovUrl' do
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
  end
end

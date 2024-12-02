RSpec.describe BulkZombieUrlUploader do
  let(:filename) { 'bulk_zombie_urls.csv' }
  let(:filepath) { Rails.root.join('features/support/bulk_zombie_urls.csv') }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:valid_csv_content) { "URL,DOC_ID\nhttp://example.com,123\nhttp://test.com,456" }

  before do
    allow(File).to receive(:read).and_return(valid_csv_content)
  end

  describe '#upload' do
    context 'when a row fails to process' do
      let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => '123' } }

      before do
        allow(CSV).to receive(:parse).and_return([row])
        allow(SearchgovUrl).to receive(:find_by).and_raise(StandardError, 'Test error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and updates the results' do
        results = uploader.upload

        expect(results.errors['http://example.com']).to include('Test error')
        expect(results.error_count).to eq(1)
        expect(Rails.logger).to have_received(:error).with(/Failure to process bulk upload zombie URL row:/)
      end
    end
  end

  describe '#process_url' do
    let(:url) { 'http://example.com' }
    let(:document_id) { '123' }

    context 'when SearchgovUrl exists' do
      let(:searchgov_url) { instance_double(SearchgovUrl) }

      before do
        allow(SearchgovUrl).to receive(:find_by).with(url:).and_return(searchgov_url)
        allow(searchgov_url).to receive(:destroy)
      end

      it 'destroys the existing SearchgovUrl' do
        uploader.send(:process_url, url, document_id)

        expect(searchgov_url).to have_received(:destroy)
      end
    end

    context 'when SearchgovUrl does not exist' do
      before do
        allow(SearchgovUrl).to receive(:find_by).with(url:).and_return(nil)
        allow(I14yDocument).to receive(:delete)
      end

      it 'deletes the I14yDocument with the given document_id' do
        uploader.send(:process_url, url, document_id)

        expect(I14yDocument).to have_received(:delete).with(handle: 'searchgov', document_id:)
      end
    end
  end
end

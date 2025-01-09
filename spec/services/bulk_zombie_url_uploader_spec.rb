# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:filename) { 'bulk_zombie_urls.csv' }
  let(:filepath) { Rails.root.join('spec/fixtures/csv/bulk_zombie_urls.csv') }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:results) { instance_double(BulkZombieUrls::Results, delete_ok: nil, increment_updated: nil, add_error: nil) }
  let(:logger) { Rails.logger }

  before do
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results)
    allow(logger).to receive(:error)
    uploader.send(:initialize_results)
  end

  describe '#upload' do
    subject(:upload) { uploader.upload }

    before do
      allow(uploader).to receive(:initialize_results).and_call_original
      allow(uploader).to receive(:process_upload)
      allow(uploader).to receive(:log_upload_error)
    end

    context 'when no errors occur' do
      it 'initializes results and processes the upload' do
        upload
        expect(uploader).to have_received(:initialize_results)
        expect(uploader).to have_received(:process_upload)
      end
    end

    context 'when an error occurs during upload' do
      let(:error) { StandardError.new('test error') }

      before do
        allow(uploader).to receive(:process_upload).and_raise(error)
      end

      it 'logs the upload error and ensures results are initialized' do
        upload
        expect(uploader).to have_received(:log_upload_error).with(error)
        expect(uploader.results).not_to be_nil
      end
    end
  end

  describe '#initialize_results' do
    it 'initializes the results object' do
      uploader.send(:initialize_results)
      expect(uploader.results).to eq(results)
    end

    it 'raises an error if results initialization fails' do
      allow(BulkZombieUrls::Results).to receive(:new).and_return(nil)
      expect { uploader.send(:initialize_results) }.to raise_error(BulkZombieUrlUploader::Error, 'Results object not initialized')
    end
  end

  describe '#process_upload' do
    let(:csv_content) { "URL,DOC_ID\nhttps://example.com,123\n" }

    before do
      allow(File).to receive(:read).with(filepath).and_return(csv_content)
      allow(uploader).to receive(:process_row)
    end

    it 'processes each row of the CSV file' do
      uploader.send(:process_upload)
      expect(uploader).to have_received(:process_row).once
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => '123' } }

    before do
      uploader.send(:initialize_results)
    end

    context 'when document ID is missing' do
      let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => nil } }

      it 'logs a missing document ID error' do
        uploader.send(:process_row, row)
        expect(results).to have_received(:add_error).with('Document ID is missing', 'https://example.com')
      end
    end

    context 'when document ID is present' do
      it 'handles URL processing' do
        allow(uploader).to receive(:handle_url_processing)
        uploader.send(:process_row, row)
        expect(uploader).to have_received(:handle_url_processing).with('https://example.com', '123', row)
      end
    end
  end

  describe '#handle_url_processing' do
    subject(:handle_url_processing) { uploader.send(:handle_url_processing, url, document_id, row) }

    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }
    let(:error) { StandardError.new('Something went wrong') }

    before do
      allow(uploader).to receive(:process_url).and_raise(error)
      allow(uploader).to receive(:handle_processing_error)
      allow(uploader).to receive(:update_results)
    end

    context 'when process_url raises an error' do
      it 'handles the error using handle_processing_error' do
        handle_url_processing
        expect(uploader).to have_received(:handle_processing_error).with(error, url, document_id, row)
      end

      it 'does not call update_results' do
        handle_url_processing
        expect(uploader).not_to have_received(:update_results)
      end
    end

    context 'when process_url succeeds' do
      before do
        allow(uploader).to receive(:process_url)
      end

      it 'calls update_results' do
        allow(uploader).to receive(:update_results)
        handle_url_processing
        expect(uploader).to have_received(:update_results).once
      end
    end
  end

  describe '#handle_processing_error' do
    subject(:handle_processing_error) do
      uploader.send(:handle_processing_error, error, url, document_id, row)
    end

    let(:error) { StandardError.new('Something went wrong') }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }

    context 'when URL is present' do
      let(:url) { 'https://example.com' }

      it 'adds an error to results with the error message and URL' do
        handle_processing_error
        expect(results).to have_received(:add_error).with('Something went wrong', url).once
      end

      it 'logs the processing error' do
        handle_processing_error
        expect(logger).to have_received(:error).with('Failure to process bulk upload zombie URL row:', error).once
      end
    end

    context 'when URL is not present' do
      let(:url) { nil }

      it 'adds an error to results with the error message and document ID' do
        handle_processing_error
        expect(results).to have_received(:add_error).with('Something went wrong', document_id).once
      end

      it 'logs the processing error' do
        handle_processing_error
        expect(logger).to have_received(:error).with('Failure to process bulk upload zombie URL row:', error).once
      end
    end
  end

  describe '#update_results' do
    it 'calls delete_ok and increment_updated on results' do
      uploader.send(:initialize_results)
      uploader.send(:update_results)

      expect(results).to have_received(:delete_ok).once
      expect(results).to have_received(:increment_updated).once
    end
  end

  describe '#delete_document' do
    let(:document_id) { '123' }

    it 'deletes the document using I14yDocument' do
      allow(I14yDocument).to receive(:delete)
      uploader.send(:delete_document, document_id)
      expect(I14yDocument).to have_received(:delete).with(handle: 'searchgov', document_id: document_id)
    end
  end

  describe '#process_url_with_searchgov' do
    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }
    let(:searchgov_url) { instance_double(SearchgovUrl, destroy: true) }

    context 'when the URL exists in SearchgovUrl' do
      before do
        allow(SearchgovUrl).to receive(:find_by).with(url: url).and_return(searchgov_url)
      end

      it 'destroys the SearchgovUrl record' do
        uploader.send(:process_url_with_searchgov, url, document_id)
        expect(searchgov_url).to have_received(:destroy)
      end
    end

    context 'when the URL does not exist in SearchgovUrl' do
      before do
        allow(SearchgovUrl).to receive(:find_by).with(url: url).and_return(nil)
        allow(uploader).to receive(:delete_document)
      end

      it 'calls delete_document with the given document_id' do
        uploader.send(:process_url_with_searchgov, url, document_id)
        expect(uploader).to have_received(:delete_document).with(document_id)
      end
    end
  end
  
  describe '#process_url' do
    subject(:process_url) { uploader.send(:process_url, url, document_id) }

    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }

    context 'when URL is present' do
      before do
        allow(uploader).to receive(:process_url_with_searchgov)
      end

      it 'calls process_url_with_searchgov with the given URL and document_id' do
        process_url
        expect(uploader).to have_received(:process_url_with_searchgov).with(url, document_id)
      end
    end

    context 'when URL is not present' do
      let(:url) { nil }

      before do
        allow(uploader).to receive(:delete_document)
      end

      it 'calls delete_document with the given document_id' do
        process_url
        expect(uploader).to have_received(:delete_document).with(document_id)
      end
    end
  end

  describe '#log_upload_error' do
    let(:error) { StandardError.new('Something went wrong') }

    it 'logs the upload error with the file name and error details' do
      allow(Rails.logger).to receive(:error)
      uploader.send(:log_upload_error, error)

      expect(Rails.logger).to have_received(:error).with(
        "Failed to process bulk zombie URL document (file: #{filename}).", error
      )
    end
  end
end

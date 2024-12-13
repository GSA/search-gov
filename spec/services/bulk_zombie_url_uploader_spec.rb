# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:filename) { 'test_file.csv' }
  let(:filepath) { '/path/to/test_file.csv' }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:results) { instance_double(BulkZombieUrls::Results, delete_ok: nil, increment_updated: nil, add_error: nil) }

  before do
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results)
    uploader.instance_variable_set(:@results, results)
  end

  describe '#initialize' do
    subject(:uploader) { described_class.new(filename, filepath) }

    it 'initializes with the given filename and filepath' do
      expect(uploader.instance_variable_get(:@file_name)).to eq(filename)
      expect(uploader.instance_variable_get(:@file_path)).to eq(filepath)
    end
  end

  describe '#upload' do
    subject(:upload) { uploader.upload }
    let(:results) { instance_double(BulkZombieUrls::Results, delete_ok: nil, increment_updated: nil) }

    before do
      allow(uploader).to receive(:initialize_results).and_call_original
      allow(uploader).to receive(:process_upload)
      allow(uploader).to receive(:results).and_return(results)
    end

    context 'when no error occurs' do
      it 'initializes results and processes the upload' do
        upload
        expect(uploader).to have_received(:initialize_results)
        expect(uploader).to have_received(:process_upload)
      end
    end

    it 'initializes results and processes the upload' do
      allow(uploader).to receive(:initialize_results).and_call_original
      allow(uploader).to receive(:process_upload)

      uploader.upload

      expect(uploader).to have_received(:initialize_results)
      expect(uploader).to have_received(:process_upload)
    end

    context 'when an error occurs' do
      let(:error) { StandardError.new('test error') }

      before do
        allow(uploader).to receive(:process_upload).and_raise(error)
        allow(uploader).to receive(:log_upload_error)
      end

      it 'logs the upload error' do
        upload
        expect(uploader).to have_received(:log_upload_error).with(error)
      end
    end
  end

  describe '#log_upload_error' do
    subject(:log_upload_error) { uploader.send(:log_upload_error, error) }

    let(:error) { StandardError.new('Upload failed') }

    context 'when backtrace is present' do
      before do
        allow(error).to receive(:backtrace).and_return(['line 1', 'line 2'])
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error with backtrace' do
        log_upload_error
        expect(Rails.logger).to have_received(:error).with(/Failed to process bulk zombie URL document \(file: test_file.csv\)\..*Error: Upload failed.*line 1.*line 2/m)
      end
    end

    context 'when backtrace is nil' do
      before do
        allow(error).to receive(:backtrace).and_return(nil)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error without backtrace' do
        log_upload_error
        expect(Rails.logger).to have_received(:error).with(/No backtrace available/)
      end
    end
  end

  describe '#initialize_results' do
    subject(:initialize_results) { uploader.send(:initialize_results) }

    context 'when results are successfully initialized' do
      before do
        allow(BulkZombieUrls::Results).to receive(:new).with(filename).and_return(instance_double(BulkZombieUrls::Results))
      end

      it 'sets the results instance variable' do
        initialize_results
        expect(uploader.results).not_to be_nil
      end
    end

    context 'when results initialization fails' do
      before do
        allow(BulkZombieUrls::Results).to receive(:new).and_return(nil)
      end

      it 'raises an error' do
        expect { initialize_results }.to raise_error(BulkZombieUrlUploader::Error, 'Results object not initialized')
      end
    end
  end

  describe '#process_upload' do
    subject(:process_upload) { uploader.send(:process_upload) }

    context 'when CSV::MalformedCSVError is not raised' do
      before do
        allow(uploader).to receive(:parse_csv).and_return([{'URL' => 'https://example.com', 'DOC_ID' => '123'}])
        allow(uploader).to receive(:process_row)
      end

      it 'parses the CSV and processes each row' do
        process_upload
        expect(uploader).to have_received(:parse_csv)
        expect(uploader).to have_received(:process_row).with('URL' => 'https://example.com', 'DOC_ID' => '123')
      end
    end

    context 'when CSV::MalformedCSVError is raised' do
      let(:error) { CSV::MalformedCSVError.new('CSV', 'Malformed CSV') }

      before do
        allow(uploader).to receive(:parse_csv).and_raise(error)
        allow(uploader).to receive(:handle_csv_error)
      end

      it 'calls handle_csv_error' do
        process_upload rescue nil
        expect(uploader).to have_received(:handle_csv_error).with(error)
      end
    end
  end

  describe '#parse_csv' do
    subject(:parse_csv) { uploader.send(:parse_csv) }

    let(:csv_content) { "URL,DOC_ID\nhttps://example.com,123\n" }

    before do
      allow(File).to receive(:read).with(filepath).and_return(csv_content)
    end

    context 'when CSV is valid' do
      it 'returns the parsed CSV object' do
        expect(parse_csv).to be_a(CSV::Table)
      end
    end

    context 'when CSV is malformed' do
      let(:csv_content) { "Invalid content" }

      it 'raises a MalformedCSVError' do
        expect { parse_csv }.to raise_error(CSV::MalformedCSVError)
      end
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => '123' } }

    context 'when document ID is present' do
      it 'processes the URL' do
        allow(uploader).to receive(:handle_url_processing)
        uploader.send(:process_row, row)
        expect(uploader).to have_received(:handle_url_processing).with('https://example.com', '123', row)
      end
    end

    context 'when document ID is missing' do
      let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => nil } }

      it 'logs a missing document ID error' do
        uploader.send(:process_row, row)
        expect(results).to have_received(:add_error).with('Document ID is missing', 'https://example.com')
      end
    end
  end

  describe '#handle_url_processing' do
    subject(:handle_url_processing) { uploader.send(:handle_url_processing, url, document_id, row) }

    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }

    context 'when StandardError is not raised during URL processing' do
      before do
        allow(uploader).to receive(:process_url_with_rescue)
        allow(uploader).to receive(:update_results)
      end

      it 'processes the URL and updates results' do
        handle_url_processing
        expect(uploader).to have_received(:process_url_with_rescue).with(url, document_id)
        expect(uploader).to have_received(:update_results)
      end
    end

    context 'when StandardError is raised during URL processing' do
      let(:error) { StandardError.new('Processing error') }

      before do
        allow(uploader).to receive(:process_url_with_rescue).and_raise(error)
        allow(uploader).to receive(:handle_processing_error)
      end

      it 'calls handle_processing_error' do
        handle_url_processing rescue nil
        expect(uploader).to have_received(:handle_processing_error).with(error, url, document_id, row)
      end
    end
  end

  describe '#update_results' do
    subject(:update_results) { uploader.send(:update_results) }

    let(:results) { instance_double(BulkZombieUrls::Results, delete_ok: nil, increment_updated: nil) }

    before do
      allow(uploader).to receive(:results).and_return(results)
    end

    it 'updates the results object' do
      uploader.send(:update_results)
      expect(results).to have_received(:delete_ok)
      expect(results).to have_received(:increment_updated)
    end
  end

  describe '#process_url_with_searchgov' do
    subject(:process_url_with_searchgov) { uploader.send(:process_url_with_searchgov, url, document_id) }

    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }

    context 'when SearchgovUrl is found' do
      let(:searchgov_url) { instance_double(SearchgovUrl, destroy: true) }

      before do
        allow(SearchgovUrl).to receive(:find_by).with(url:).and_return(searchgov_url)
      end

      it 'destroys the SearchgovUrl record' do
        process_url_with_searchgov
        expect(searchgov_url).to have_received(:destroy)
      end
    end

    context 'when SearchgovUrl is not found' do
      before do
        allow(SearchgovUrl).to receive(:find_by).with(url:).and_return(nil)
        allow(uploader).to receive(:delete_document)
      end

      it 'deletes the document' do
        process_url_with_searchgov
        expect(uploader).to have_received(:delete_document).with(document_id)
      end
    end
  end

  describe '#process_url' do
    subject(:process_url) { uploader.send(:process_url, url, document_id) }

    let(:document_id) { '123' }

    context 'when URL is present' do
      let(:url) { 'https://example.com' }

      before do
        allow(uploader).to receive(:process_url_with_searchgov)
      end

      it 'processes the URL with Searchgov' do
        process_url
        expect(uploader).to have_received(:process_url_with_searchgov).with(url, document_id)
      end
    end

    context 'when URL is not present' do
      let(:url) { nil }

      before do
        allow(uploader).to receive(:delete_document)
      end

      it 'deletes the document' do
        process_url
        expect(uploader).to have_received(:delete_document).with(document_id)
      end
    end
  end

  describe '#handle_csv_error' do
    subject(:handle_csv_error) { uploader.send(:handle_csv_error, error) }

    let(:error) { CSV::MalformedCSVError.new('CSV', 'Malformed CSV') }

    it 'logs an error for invalid CSV format' do
      allow(Rails.logger).to receive(:error)
      handle_csv_error
      expect(results).to have_received(:add_error).with('Invalid CSV format', 'Entire file')
      expect(Rails.logger).to have_received(:error).with(/Error parsing CSV: .*Malformed CSV/)
    end
  end

  describe '#handle_processing_error' do
    subject(:handle_processing_error) { uploader.send(:handle_processing_error, error, url, document_id, row) }

    let(:error) { StandardError.new('Processing error') }
    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }

    before do
      allow(Rails.logger).to receive(:error)
    end

    it 'logs and records an error when a processing error occurs' do
      handle_processing_error
      expect(results).to have_received(:add_error).with('Processing error', url)
      expect(Rails.logger).to have_received(:error).with(/Failure to process bulk upload zombie URL row:/)
    end

    context 'when URL is blank' do
      let(:url) { nil }

      it 'uses the document ID as the key for the error' do
        handle_processing_error
        expect(results).to have_received(:add_error).with('Processing error', document_id)
      end
    end

    context 'when backtrace is nil' do
      before do
        allow(error).to receive(:backtrace).and_return(nil)
      end

      it 'logs the error without backtrace' do
        handle_processing_error
        expect(Rails.logger).to have_received(:error).with(/No backtrace available/)
      end
    end
  end
  
  describe '#delete_document' do
    subject(:delete_document) { uploader.send(:delete_document, document_id) }

    let(:document_id) { '123' }

    before do
      allow(I14yDocument).to receive(:delete)
    end

    it 'deletes the document from I14yDocument' do
      delete_document
      expect(I14yDocument).to have_received(:delete).with(handle: 'searchgov', document_id:)
    end
  end

  describe '#process_url_with_rescue' do
    subject(:process_url_with_rescue) { uploader.send(:process_url_with_rescue, url, document_id) }

    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }

    before do
      allow(uploader).to receive(:process_url)
    end

    it 'calls process_url' do
      process_url_with_rescue
      expect(uploader).to have_received(:process_url).with(url, document_id)
    end
  end
end

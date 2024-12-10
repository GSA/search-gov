# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:filename) { 'test_file.csv' }
  let(:filepath) { Rails.root.join('spec', 'fixtures', 'files', filename) }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:results_double) { instance_double('BulkZombieUrls::Results') }

  before do
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results_double)
    allow(results_double).to receive(:add_error)
    allow(results_double).to receive(:delete_ok)
    allow(results_double).to receive(:increment_updated)
  end

  describe '#initialize' do
    it 'assigns filename and filepath' do
      expect(uploader.instance_variable_get(:@file_name)).to eq(filename)
      expect(uploader.instance_variable_get(:@file_path)).to eq(filepath)
      expect(uploader.results).to be_nil
    end
  end

  describe '#upload' do
    subject { uploader.upload }

    before do
      allow(uploader).to receive(:initialize_results).and_call_original
      allow(uploader).to receive(:process_upload)
      allow(uploader).to receive(:log_upload_error)
    end

    it 'initializes results correctly' do
      expect { subject }.not_to raise_error
    end

    context 'when no error occurs' do
      it 'initializes results correctly' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when an error occurs' do
      let(:error) { StandardError.new('Test Error') }

      before do
        allow(uploader).to receive(:process_upload).and_raise(error)
      end

      it 'logs the upload error' do
        expect(uploader).to receive(:log_upload_error).with(error)
        subject
      end
    end
  end

  describe '#initialize_results' do
    subject { uploader.send(:initialize_results) }

    it 'initializes the @results object' do
      expect { subject }.not_to raise_error
      expect(uploader.instance_variable_get(:@results)).to eq(results_double)
    end
  end

  describe '#process_upload' do
    subject { uploader.send(:process_upload) }

    let(:csv_content) { "URL,DOC_ID\nhttp://example.com,123\n" }
    let(:parsed_csv) { CSV.parse(csv_content, headers: true) }

    before do
      allow(File).to receive(:read).with(filepath).and_return(csv_content)
      allow(CSV).to receive(:parse).and_return(parsed_csv)
      allow(uploader).to receive(:process_row)
    end

    it 'parses the CSV and processes each row' do
      expect(CSV).to receive(:parse).and_return(parsed_csv)
      expect(uploader).to receive(:process_row).with(parsed_csv.first)
      subject
    end
  end

  describe '#parse_csv' do
    subject { uploader.send(:parse_csv) }

    let(:csv_content) { "URL,DOC_ID\nhttp://example.com,123\n" }

    before do
      allow(File).to receive(:read).with(filepath).and_return(csv_content)
    end

    context 'with valid CSV headers' do
      it 'returns parsed CSV' do
        expect(subject).to be_a(CSV::Table)
      end
    end

    context 'with missing headers' do
      let(:csv_content) { "INVALID_HEADER\nhttp://example.com\n" }

      it 'raises a CSV::MalformedCSVError' do
        expect { subject }.to raise_error(CSV::MalformedCSVError)
      end
    end
  end

  describe '#process_row' do
    subject { uploader.send(:process_row, row) }

    let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => '123' } }

    context 'when @results is not initialized' do
      before do
        uploader.instance_variable_set(:@results, nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(BulkZombieUrlUploader::Error, 'Results object not initialized')
      end
    end

    context 'when @results is initialized' do
      before do
        uploader.send(:initialize_results)
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#handle_url_processing' do
    subject { uploader.send(:handle_url_processing, url, document_id, row) }

    let(:url) { 'http://example.com' }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }

    context 'when no error occurs' do
      before do
        allow(uploader).to receive(:process_url_with_rescue)
        allow(uploader).to receive(:update_results)
      end

      it 'processes the URL and updates results' do
        expect(uploader).to receive(:process_url_with_rescue).with(url, document_id)
        expect(uploader).to receive(:update_results)
        subject
      end
    end

    context 'when an error occurs' do
      let(:error) { StandardError.new('Test Error') }

      before do
        allow(uploader).to receive(:process_url_with_rescue).and_raise(error)
        allow(uploader).to receive(:handle_processing_error)
      end

      it 'handles processing error' do
        expect(uploader).to receive(:handle_processing_error).with(error, url, document_id, row)
        subject
      end
    end
  end

  describe '#process_url' do
    subject { uploader.send(:process_url, url, document_id) }

    let(:document_id) { '123' }

    context 'when URL is present' do
      let(:url) { 'http://example.com' }

      before do
        allow(uploader).to receive(:process_url_with_searchgov)
      end

      it 'processes URL with Searchgov' do
        expect(uploader).to receive(:process_url_with_searchgov).with(url, document_id)
        subject
      end
    end

    context 'when URL is blank' do
      let(:url) { nil }

      before do
        allow(uploader).to receive(:delete_document)
      end

      it 'deletes the document' do
        expect(uploader).to receive(:delete_document).with(document_id)
        subject
      end
    end
  end
end

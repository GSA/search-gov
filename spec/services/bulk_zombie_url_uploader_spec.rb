# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:filename) { 'test_file.csv' }
  let(:filepath) { '/path/to/test_file.csv' }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:results) { instance_double(BulkZombieUrls::Results) }
  let(:csv_content) do
    <<~CSV
      URL,DOC_ID
      http://example.com,doc1
      ,doc2
      http://missingdoc.com,
    CSV
  end

  before do
    allow(File).to receive(:read).with(filepath).and_return(csv_content)
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results)
    allow(results).to receive(:add_error)
    allow(results).to receive(:delete_ok)
    allow(results).to receive(:increment_updated)
    uploader.instance_variable_set(:@results, results) # Ensure `@results` is initialized
  end

  describe '#initialize' do
    it 'assigns filename and filepath' do
      expect(uploader.instance_variable_get(:@file_name)).to eq(filename)
      expect(uploader.instance_variable_get(:@file_path)).to eq(filepath)
    end
  end

  describe '#upload_urls' do
    context 'with valid CSV content' do
      it 'processes each row in the CSV' do
        allow(uploader).to receive(:process_row)
        uploader.send(:upload_urls)
        expect(uploader).to have_received(:process_row).exactly(3).times
      end
    end

    context 'with invalid CSV content' do
      let(:csv_error) { CSV::MalformedCSVError.new('Invalid CSV format', 'Line causing error') }

      before do
        allow(CSV).to receive(:parse).and_raise(csv_error)
        allow(Rails.logger).to receive(:error)
      end

      it 'handles the CSV error and logs it' do
        expect(results).to receive(:add_error).with('Invalid CSV format', 'Entire file')
        uploader.send(:upload_urls)
        expect(Rails.logger).to have_received(:error).with(/Error parsing CSV/)
      end
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => 'doc1' } }

    context 'when DOC_ID is blank' do
      let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => nil } }

      it 'adds an error and logs it' do
        allow(Rails.logger).to receive(:error)
        uploader.send(:process_row, row)
        expect(results).to have_received(:add_error).with('Document ID is missing', 'http://example.com')
        expect(Rails.logger).to have_received(:error).with(/Document ID is mandatory/)
      end
    end
  end

  describe '#process_url_with_rescue' do
    let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => 'doc1' } }

    before do
      allow(uploader).to receive(:process_url)
    end

    it 'processes the URL and updates results' do
      uploader.send(:process_url_with_rescue, 'http://example.com', 'doc1', row)
      expect(results).to have_received(:delete_ok)
      expect(results).to have_received(:increment_updated)
    end

    context 'when an error occurs during processing' do
      let(:error) { StandardError.new('Processing error') }

      before do
        allow(uploader).to receive(:process_url).and_raise(error)
        allow(Rails.logger).to receive(:error)
      end

      it 'handles the error and logs it' do
        uploader.send(:process_url_with_rescue, 'http://example.com', 'doc1', row)
        expect(results).to have_received(:add_error).with('Processing error', 'http://example.com')
        expect(Rails.logger).to have_received(:error).with(/Failure to process bulk upload zombie URL row/)
      end
    end
  end
end

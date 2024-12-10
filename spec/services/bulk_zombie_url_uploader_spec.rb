# frozen_string_literal: true

describe BulkZombieUrlUploader do
  let(:file_name) { 'bulk_zombie_urls.csv' }
  let(:file_path) { Rails.root.join('spec/fixtures/csv/bulk_zombie_urls.csv') }
  let(:uploader) { described_class.new(file_name, file_path) }
  let(:results_double) { instance_double(BulkZombieUrls::Results, add_error: nil, delete_ok: nil, increment_updated: nil) }

  before do
    allow(File).to receive(:read).and_call_original
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results_double)
  end

  describe '#initialize' do
    it 'sets file name and path instance variables' do
      expect(uploader.instance_variable_get(:@file_name)).to eq(file_name)
      expect(uploader.instance_variable_get(:@file_path)).to eq(file_path)
    end
  end

  describe '#upload' do
    context 'successful upload' do
      before do
        allow(uploader).to receive(:process_upload).and_return(nil)
        allow(results_double).to receive(:delete_ok)
        allow(results_double).to receive(:increment_updated)
      end

      it 'initializes results and processes URLs' do
        expect { uploader.upload }.not_to raise_error
        expect(BulkZombieUrls::Results).to have_received(:new).with(file_name)
        expect(uploader).to have_received(:process_upload)
      end

      # it 'returns the results object' do
      #   expect(uploader.upload).to eq(results_double)
      #   expect(uploader.results).to eq(results_double)
      # end
    end
  end

  describe '#parse_csv' do
    let(:file_content) { "URL,DOC_ID\nhttps://example.com,123\n" }
    let(:malformed_csv_content) { "malformed,data" }
  
    context 'when the CSV is valid' do
      before do
        allow(File).to receive(:read).with(file_path).and_return(file_content)
      end
  
      it 'parses the CSV successfully' do
        expect { uploader.send(:parse_csv) }.not_to raise_error
      end
    end
  
    context 'when the CSV raises an error' do
      before do
        allow(File).to receive(:read).with(file_path).and_return(malformed_csv_content)
        allow(CSV).to receive(:parse).and_raise(ArgumentError, 'Invalid argument')
      end
  
      it 'raises CSV::MalformedCSVError' do
        expect { uploader.send(:parse_csv) }.to raise_error(CSV::MalformedCSVError, /Malformed or invalid CSV: Invalid argument/)
      end
    end
  end

  describe '#process_upload' do
    let(:csv_content) { "URL,DOC_ID\nhttps://example.com,123\nhttps://example2.com,\n" }
    let(:malformed_csv_content) { "malformed,data" }

    before do
      uploader.instance_variable_set(:@results, results_double)
    end

    context 'when the CSV is valid' do
      before do
        allow(File).to receive(:read).with(file_path).and_return(csv_content)
        allow(uploader).to receive(:process_row)
      end

      it 'parses and processes each row' do
        expect { uploader.send(:process_upload) }.not_to raise_error
        expect(uploader).to have_received(:process_row).twice
      end
    end

    context 'when the CSV is malformed' do
      before do
        allow(File).to receive(:read).with(file_path).and_return(malformed_csv_content)
        allow(CSV).to receive(:parse).and_raise(CSV::MalformedCSVError.new('CSV', 'Malformed or invalid CSV'))
        allow(Rails.logger).to receive(:error)
      end
  
      it 'logs the error and adds it to results' do
        expect { uploader.send(:process_upload) }.not_to raise_error
        expect(results_double).to have_received(:add_error).with('Invalid CSV format', 'Entire file')
        expect(Rails.logger).to have_received(:error).with(/Malformed or invalid CSV/)
      end
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => '123' } }

    before do
      uploader.instance_variable_set(:@results, results_double)
      allow(uploader).to receive(:handle_url_processing).and_return(nil)
    end

    context 'missing DOC_ID' do
      let(:row) { { 'URL' => 'https://example.com', 'DOC_ID' => '' } }

      it 'adds an error and logs the issue' do
        uploader.send(:process_row, row)
        expect(results_double).to have_received(:add_error).with('Document ID is missing', 'https://example.com')
      end
    end

    context 'valid DOC_ID' do
      it 'handles URL processing successfully' do
        uploader.send(:process_row, row)
        expect(uploader).to have_received(:handle_url_processing).with('https://example.com', '123', row)
      end
    end
  end

  describe '#handle_url_processing' do
    let(:url) { 'https://example.com' }
    let(:document_id) { '123' }
    let(:row) { { 'URL' => url, 'DOC_ID' => document_id } }

    before do
      uploader.instance_variable_set(:@results, results_double)
      allow(uploader).to receive(:update_results)
    end

    context 'successful processing' do
      before do
        allow(uploader).to receive(:process_url).and_return(nil)
      end

      it 'updates results without error' do
        expect { uploader.send(:handle_url_processing, url, document_id, row) }.not_to raise_error
        expect(uploader).to have_received(:update_results)
      end
    end

    context 'failed processing' do
      before do
        allow(uploader).to receive(:process_url).and_raise(StandardError, 'Processing error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and adds it to results' do
        expect { uploader.send(:handle_url_processing, url, document_id, row) }.not_to raise_error
        expect(results_double).to have_received(:add_error).with('Processing error', url)
        expect(Rails.logger).to have_received(:error).with(/Failure to process bulk upload zombie URL row/)
      end
    end
  end
end

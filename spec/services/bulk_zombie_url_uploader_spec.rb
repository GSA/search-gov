# frozen_string_literal: true

require 'spec_helper'

describe BulkZombieUrlUploader do
  let(:valid_file_path) { 'spec/fixtures/files/valid_zombie_urls.csv' }
  let(:invalid_file_path) { 'spec/fixtures/files/invalid_zombie_urls.csv' }
  let(:filename) { 'valid_zombie_urls.csv' }
  let(:uploader) { described_class.new(filename, valid_file_path) }
  let(:results) { instance_double(BulkZombieUrls::Results) }

  before do
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results)
    allow(results).to receive(:add_error)
    allow(results).to receive(:delete_ok)
    allow(results).to receive(:updated=)
    allow(results).to receive(:updated).and_return(0)
    allow(results).to receive(:ok_count).and_return(0)
    allow(results).to receive(:error_count).and_return(0)
    allow(File).to receive(:read).with(valid_file_path).and_return("URL,DOC_ID\nhttp://example.com,123\n")
    allow(File).to receive(:read).with(invalid_file_path).and_raise(CSV::MalformedCSVError.new('Malformed CSV', 1))
    allow(SearchgovUrl).to receive(:find_by).and_return(nil)
    allow(I14yDocument).to receive(:delete).and_return(true)
    uploader.instance_variable_set(:@results, results)
  end

  describe '#upload' do
    context 'with a valid CSV' do
      it 'processes valid CSV rows successfully' do
        expect(results).to receive(:delete_ok)
        expect(results).to receive(:updated=).with(1)
        uploader.upload
      end
    end

    context 'with an invalid CSV format' do
      it 'handles invalid CSV format gracefully' do
        uploader = described_class.new(filename, invalid_file_path)
        expect(results).to receive(:add_error).with('Invalid CSV format', 'Entire file')
        uploader.upload
      end
    end

    context 'when an unexpected error occurs during processing' do
      it 'logs the error' do
        allow(uploader).to receive(:upload_urls).and_raise(StandardError, 'Unexpected error')
        expect(Rails.logger).to receive(:error).with(/Problem processing bulk zombie URL document/)
        uploader.upload
      end
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => '123' } }

    it 'processes rows with valid data' do
      expect(results).to receive(:delete_ok)
      expect(results).to receive(:updated=).with(1)
      uploader.send(:process_row, row)
    end

    it 'logs an error and skips rows with missing Document IDs' do
      row['DOC_ID'] = nil
      expect(results).to receive(:add_error).with('Document ID is missing', 'http://example.com')
      uploader.send(:process_row, row)
    end
  end

  describe '#handle_csv_error' do
    it 'adds a CSV error to results and logs it' do
      expect(results).to receive(:add_error).with('Invalid CSV format', 'Entire file')
      expect(Rails.logger).to receive(:error).with(/Error parsing CSV/)
      uploader.send(:handle_csv_error, CSV::MalformedCSVError.new('Malformed CSV', 1))
    end
  end
end

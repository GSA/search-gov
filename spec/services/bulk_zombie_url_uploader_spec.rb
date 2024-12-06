# frozen_string_literal: true

require 'spec_helper'

describe BulkZombieUrlUploader do
  let(:valid_file_path) { 'spec/fixtures/files/valid_zombie_urls.csv' }
  let(:invalid_file_path) { 'spec/fixtures/files/invalid_zombie_urls.csv' }
  let(:filename) { 'valid_zombie_urls.csv' }
  let(:uploader) { described_class.new(filename, valid_file_path) }
  let(:results) { instance_spy(BulkZombieUrls::Results) }
  let(:logger) { instance_double(Logger, error: nil, info: nil, debug: nil) }

  before do
    allow(BulkZombieUrls::Results).to receive(:new).and_return(results)
    allow(results).to receive(:add_error)
    allow(results).to receive(:delete_ok)
    allow(results).to receive(:increment_updated)
    allow(File).to receive(:read).with(valid_file_path).and_return("URL,DOC_ID\nhttp://example.com,123\n")
    allow(File).to receive(:read).with(invalid_file_path).and_raise(CSV::MalformedCSVError.new('Malformed CSV', 1))
    allow(SearchgovUrl).to receive(:find_by).and_return(instance_double('SearchgovUrl', destroy: true))
    allow(I14yDocument).to receive(:delete).and_return(true)
    allow(Rails).to receive(:logger).and_return(logger)
    uploader.instance_variable_set(:@results, results)
  end

  describe '#upload' do
    context 'with a valid CSV' do
      it 'processes valid CSV rows successfully' do
        uploader.upload
        expect(results).to have_received(:delete_ok).once
        expect(results).to have_received(:increment_updated).once
      end
    end

    context 'with an invalid CSV format' do
      it 'handles invalid CSV format gracefully' do
        uploader = described_class.new(filename, invalid_file_path)
        uploader.upload
        expect(results).to have_received(:add_error).with('Invalid CSV format', 'Entire file').once
        expect(logger).to have_received(:error).with(/Error parsing CSV/)
      end
    end
  end

  describe '#process_row' do
    let(:row) { { 'URL' => 'http://example.com', 'DOC_ID' => '123' } }

    it 'processes rows with valid data' do
      uploader.send(:process_row, row)
      expect(results).to have_received(:delete_ok).once
      expect(results).to have_received(:increment_updated).once
    end
  end
end

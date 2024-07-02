describe BulkAffiliateStylesUploader do
  let(:valid_file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', size: 1.megabyte, original_filename: 'test.csv') }
  let(:invalid_file_type) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'application/json', size: 1.megabyte) }
  let(:large_file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', size: 5.megabytes) }
  let(:empty_file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', size: 0) }
  let(:filename) { 'test.csv' }
  let(:filepath) { Rails.root.join('spec/fixtures/files/test.csv') }
  let(:uploader) { described_class.new(filename, filepath) }

  describe BulkAffiliateStylesUploader::AffiliateStylesFileValidator do
    let(:validator) { described_class.new(valid_file) }

    context 'when file is valid' do
      it 'does not raise an error' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when file is not present' do
      let(:validator) { described_class.new(nil) }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(BulkAffiliateStylesUploader::Error, 'Please choose a file to upload.')
      end
    end

    context 'when file type is invalid' do
      let(:validator) { described_class.new(invalid_file_type) }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(BulkAffiliateStylesUploader::Error, 'Files of type application/json are not supported.')
      end
    end

    context 'when file size is too big' do
      let(:validator) { described_class.new(large_file) }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(BulkAffiliateStylesUploader::Error, 'test.csv is too big; please split it.')
      end
    end
  end

  describe '#upload' do
    context 'when processing a valid file' do
      before do
        allow(File).to receive(:read).and_return(File.read(filepath))
        allow(CSV).to receive(:parse).and_return([{ 'ID' => '1', 'banner_background_color' => '#ffffff' }])
        allow(Affiliate).to receive(:find).and_return(instance_double(Affiliate, id: 1, primary_header_links: [], secondary_header_links: [], footer_links: [], identifier_links: [], visual_design_json: {}))
      end

      it 'returns a Results object with the correct attributes' do
        results = uploader.upload

        expect(results).to be_a(BulkAffiliateStylesUploader::Results)
        expect(results.file_name).to eq(filename)
        expect(results.ok_count).to eq(1)
        expect(results.error_count).to eq(0)
        expect(results.affiliates).to include('1')
      end
    end

    context 'when processing an invalid file' do
      before do
        allow(File).to receive(:read).and_return(File.read(filepath))
        allow(CSV).to receive(:parse).and_raise(StandardError.new('Invalid CSV format'))
      end

      it 'logs an error and returns a Results object with errors' do
        expect(Rails.logger).to have_received(:error).with(/Problem processing boosted Content document/)
        results = uploader.upload

        expect(results).to be_a(BulkAffiliateStylesUploader::Results)
        expect(results.file_name).to eq(filename)
        expect(results.ok_count).to eq(0)
        expect(results.error_count).to eq(0)
        expect(results.affiliates).to be_empty
        expect(results.instance_variable_get(:@errors)).to be_empty
      end
    end
  end
end

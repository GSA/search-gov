describe BulkAffiliateStyles::FileValidator do
  let(:validator) { described_class.new(valid_file) }
  let(:large_file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', size: 5.megabytes, original_filename: 'affiliate_styles.csv') }
  let(:valid_file) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'text/csv', size: 1.megabyte, original_filename: 'affiliate_styles.csv') }
  let(:invalid_file_type) { instance_double(ActionDispatch::Http::UploadedFile, content_type: 'application/json', size: 1.megabyte) }

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
      expect { validator.validate! }.to raise_error(BulkAffiliateStylesUploader::Error, 'affiliate_styles.csv is too big; please split it.')
    end
  end
end

# frozen_string_literal: true

describe BulkZombieUrls::FileValidator do
  let(:file) do
    instance_double(
      ActionDispatch::Http::UploadedFile,
      size: file_size,
      content_type: file_content_type,
      original_filename: 'file.csv'
    )
  end
  let(:validator) { described_class.new(file) }
  let(:file_size) { 3.megabytes }
  let(:file_content_type) { 'text/csv' }

  describe '#validate!' do
    context 'when the file is valid' do
      it 'does not raise an error' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when the file is missing' do
      let(:file) { nil }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(
          BulkZombieUrlUploader::Error,
          %r{Please choose a file to upload}
        )
      end
    end

    context 'when the file is too large' do
      let(:file_size) { 5.megabytes }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(
          BulkZombieUrlUploader::Error,
          %r{file.csv is too big; please split it}
        )
      end
    end

    context 'when the file type is invalid' do
      let(:file_content_type) { 'application/pdf' }

      it 'raises an error' do
        expect { validator.validate! }.to raise_error(
          BulkZombieUrlUploader::Error,
          %r{Files of type application/pdf are not supported}
        )
      end
    end
  end
end

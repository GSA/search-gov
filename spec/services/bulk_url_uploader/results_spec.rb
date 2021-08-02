# frozen_string_literal: true

describe BulkUrlUploader::Results do
  subject(:results) { described_class.new('test bulk uploader') }

  describe '#errors' do
    context 'when there are "url already taken" errors' do
      before do
        results.add_error('Validation failed: Url has already been taken', 'https://irrelevant-to-the-spec.gov')
        results.add_error('Validation failed: SearchgovDomain is not a valid SearchgovDomain', 'https://irrelevant-to-the-spec.gov')
      end

      it 'puts them at the end of the list' do
        expect(results.error_messages).to eq(
          [
            'Validation failed: SearchgovDomain is not a valid SearchgovDomain',
            'Validation failed: Url has already been taken'
          ]
        )
      end
    end
  end
end

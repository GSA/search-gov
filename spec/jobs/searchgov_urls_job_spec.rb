require 'spec_helper'

describe SearchgovUrlsJob do
  let(:name) { '12345' }
  let(:urls) do
    [
      'https://agency.gov/one-url',
      'https://agency.gov/another-url'
    ]
  end

  describe '#perform' do
    it 'urls are received by SearchgovUrl' do
      described_class.perform_now(name, urls)
      expect(SearchgovUrl.find_by(url: urls[0])).not_to be_nil
      expect(SearchgovUrl.find_by(url: urls[1])).not_to be_nil
    end

    it 'upload_and_index method is called' do
      uploader = instance_spy(
        BulkUrlUploader,
        upload_and_index: nil,
        results: instance_double(
          BulkUrlUploader::Results,
          name: 'Test Results',
          total_count: 10,
          error_count: 2
        )
      )
      allow(BulkUrlUploader).to receive(:new).and_return(uploader)
      described_class.perform_now(name, urls)
      expect(uploader).to have_received(:upload_and_index)
    end
  end
end

require 'spec_helper'

describe SearchgovUrlFetcherJob do
  subject(:perform) { SearchgovUrlFetcherJob.perform_now(searchgov_url) }
  let!(:searchgov_url) { SearchgovUrl.create(url: 'https://agency.gov/') }
  let(:args) do
    { searchgov_url: searchgov_url }
  end

  it_behaves_like 'a searchgov job'

  describe '#perform' do
    it 'must have one parameter' do
      expect{ SearchgovUrlFetcherJob.perform_now }.
        to raise_error(ArgumentError)
    end

    it 'fetches a searchgov_url' do
      expect(searchgov_url).to receive(:fetch)
      perform
    end
  end
end
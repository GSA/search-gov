require 'spec_helper'

describe SearchgovUrlFetcherJob do
  fixtures :searchgov_domain

  subject(:perform) { SearchgovUrlFetcherJob.perform_now(args) }
  let!(:searchgov_url) { SearchgovUrl.create!(url: 'https://agency.gov/') }
  let(:args) do
    { searchgov_url: searchgov_url }
  end

  it_behaves_like 'a searchgov job'

  describe '#perform' do
    it 'requires a searchgov_url' do
      expect{ SearchgovUrlFetcherJob.perform_now }.
        to raise_error(ArgumentError, 'missing keyword: searchgov_url')
    end

    it 'fetches a searchgov_url' do
      expect(searchgov_url).to receive(:fetch)
      perform
    end
  end
end

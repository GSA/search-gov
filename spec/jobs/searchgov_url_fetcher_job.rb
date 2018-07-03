require 'spec_helper'

describe SearchgovUrlFetcherJob do
  subject(:perform) { SearchgovUrlFetcherJob.perform_now(searchgov_url) }
  let!(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov', status: '200') }
  let(:searchgov_url) { SearchgovUrl.create(url: 'https://agency.gov/') }
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
      perform
      expect(searchgov_url.last_crawl_status).to_not be(nil)
    end
  end
end
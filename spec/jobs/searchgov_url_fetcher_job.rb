require 'spec_helper'

describe SearchgovUrlFetcherJob do
  subject(:perform) { SearchgovUrlFetcherJob.perform_now(searchgov_url) }
  let!(:searchgov_url) { SearchgovUrl.create(url: 'https://agency.gov/') }
  let(:args) do
    { searchgov_url: searchgov_url }
  end

  it_behaves_like 'a searchgov job'

  # context 'when fetching a url' do
    # before do
    #   perform
    # end

    it 'fetches a searchgov_url' do
      perform
      expect(searchgov_url.last_crawl_status).to_not be(nil)
    end
  #
  #   it 'displays a flash message' do
  #     expect(flash[:info]).to be_present
  #   end
  # end

end
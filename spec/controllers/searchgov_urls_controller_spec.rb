require 'spec_helper'

describe Admin::SearchgovUrlsController do
  # let!(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov')}
  let(:searchgov_url) { SearchgovUrl.create(url: 'agency.gov/test') }
  let(:params) do
    { association: 'searchgov_urls', parent_scaffold: 'admin/searchgov_domains',
    searchgov_domain_id: searchgov_url.searchgov_domain.id, id: searchgov_url.id }
  end

  describe '#fetch' do
    # before do
    #   # post :fetch, association: 'searchgov_urls', parent_scaffold: 'admin/searchgov_domains',
    #   # searchgov_domain_id: searchgov_url.searchgov_domain.id, id: searchgov_url.id
    #   # post "/admin/searchgov_domains/#{searchgov_url.searchgov_domain.id}/searchgov_urls/#{searchgov_url.id}/fetch?_method=post&association=searchgov_urls&parent_scaffold=admin%2Fsearchgov_domains&searchgov_domain_id=#{searchgov_url.searchgov_domain.id}"
    #   post :fetch, params
    #   p response.body
    # end

    it 'enqueues a searchgov_url_fetcher_job to the searchgov queue' do
      # ActiveJob::Base.queue_adapter = :test
      expect{ post :fetch, params }.
        to have_enqueued_job(SearchgovUrlFetcherJob).on_queue("searchgov")
    end
  end
end
require 'spec_helper'

describe Admin::SearchgovUrlsController do
  let(:searchgov_url) { SearchgovUrl.create!(url: 'agency.gov/test') }
  let(:params) do
    { association: 'searchgov_urls', parent_scaffold: 'admin/searchgov_domains',
    searchgov_domain_id: searchgov_url.searchgov_domain.id, id: searchgov_url.id }
  end

  include_context 'super admin logged in' do
    describe '#fetch' do
      it 'enqueues a searchgov_url_fetcher_job to the searchgov queue' do
        expect{ post :fetch, params }.
          to have_enqueued_job(SearchgovUrlFetcherJob).on_queue("searchgov").
          with(searchgov_url: searchgov_url)
      end
    end
  end
end
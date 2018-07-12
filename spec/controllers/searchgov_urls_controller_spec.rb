require 'spec_helper'

describe Admin::SearchgovUrlsController do
  fixtures :users

  let(:admin) { users(:affiliate_admin) }
  let(:searchgov_url) { SearchgovUrl.create(url: 'agency.gov/test') }
  let(:params) do
    { association: 'searchgov_urls', parent_scaffold: 'admin/searchgov_domains',
    searchgov_domain_id: searchgov_url.searchgov_domain.id, id: searchgov_url.id }
  end

  context 'when logged in as an admin' do
    describe '#fetch' do
      before do
        activate_authlogic
        UserSession.create admin
        allow(SearchgovDomainPreparerJob).to receive(:perform_later)
      end

      it 'enqueues a searchgov_url_fetcher_job to the searchgov queue' do
        expect{ post :fetch, params }.
          to have_enqueued_job(SearchgovUrlFetcherJob).on_queue("searchgov")
      end
    end
  end
end
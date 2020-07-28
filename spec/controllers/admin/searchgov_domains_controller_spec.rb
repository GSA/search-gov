require 'spec_helper'

describe Admin::SearchgovDomainsController do
  let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end

  include_context 'super admin logged in' do
    describe '#reindex' do
      subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex on the domain' do
        expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
          with(searchgov_domain: searchgov_domain)
      end
    end
  end
end

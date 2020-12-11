# frozen_string_literal: true

describe 'Searchgov Domain Management' do
  let(:url) { '/admin/searchgov_domains' }

  it_behaves_like 'a page restricted to super admins'

  describe 'reindexing a domain' do
    include_context 'log in super admin'

    subject(:reindex) do
      visit url
      click_link('Reindex', match: :first)
    end

    it 'triggers a reindex of the domain' do
       expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
         with(searchgov_domain: instance_of(SearchgovDomain))
    end
  end
end

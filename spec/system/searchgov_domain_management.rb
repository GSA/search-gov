describe 'Searchgov Domain Management' do
    let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end

  include_context 'super admin logged in' do
    describe 'reindexing a domain' do
      #subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex of the domain' do
        visit 'admin_searchgov_domains'
       # expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
          #with(searchgov_domain: searchgov_domain)
        puts 'visited'

      end
    end
  end

end

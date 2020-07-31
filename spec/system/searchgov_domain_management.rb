describe 'Searchgov Domain Management' do
    let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end
    let(:current_user) { users(:affiliate_admin) }
    before do
      Rails.application.env_config["omniauth.auth"] = mock_user_auth('affiliate_admin@fixtures.org')
    end

    describe 'reindexing a domain' do
      #subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex of the domain' do
        puts "visiting login"
        visit 'login'

        puts "clicking accept & proceed"
        click_button 'Accept and proceed'

        puts "visiting super admin searchgov_domains"
        visit 'admin/searchgov_domains'
        click_link 'Reindex'
       # expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
          #with(searchgov_domain: searchgov_domain)
      end
    end
end

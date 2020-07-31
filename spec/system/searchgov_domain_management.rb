describe 'Searchgov Domain Management' do
    let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end
    let(:current_user) { users(:affiliate_admin) }
    before do
      mock_user_auth('affiliate_admin@fixtures.org')
    end


    describe 'reindexing a domain' do
      #subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex of the domain' do
OmniAuth.config.test_mode = true
auth = mock_user_auth('affiliate_admin@fixtures.org')
       Rails.application.env_config["omniauth.auth"] = auth
       #puts "mocked: #{Rails.application.env_config["omniauth.auth"] }".blue
       # request.env['omniauth.auth'] = mock_user_auth('affiliate_admin@fixtures.org')
 mock_user_auth('affiliate_admin@fixtures.org')
       puts "current user uid: #{current_user.uid}"
       puts "visiting login"
      # Rails.application.env_config["omniauth.auth"] = mock_user_auth('affiliate_admin@fixtures.org')
        visit 'login'
        puts "clicking accept & proceed"
       #Rails.application.env_config["omniauth.auth"] = mock_user_auth('affiliate_admin@fixtures.org')
        click_button 'Accept and proceed'

        puts "visiting sd"
        visit 'admin/searchgov_domains'
        click_link 'Reindex'
       # expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
          #with(searchgov_domain: searchgov_domain)
        puts 'visited'

      end
    end

end

=begin
# working...
# describe 'Searchgov Domain Management' do
    let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end

    describe 'reindexing a domain' do
      #subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex of the domain' do

        mock_user_auth('affiliate_admin@fixtures.org')
        visit 'login'
        visit 'admin/searchgov_domains'
       # expect { reindex }.to have_enqueued_job(SearchgovDomainReindexerJob).
          #with(searchgov_domain: searchgov_domain)
        puts 'visited'

      end
    end

=end

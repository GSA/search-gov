require 'spec_helper'

describe Sites::SiteDomainsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:site_domains) { mock('domains') }

      before do
        site.should_receive(:site_domains).and_return(site_domains)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:site_domains).with(site_domains) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are valid' do
        let(:site_domain) { mock_model(SiteDomain, domain: 'usa.gov') }

        before do
          site_domains_arel = mock('site domains arel')
          site.stub(:site_domains).and_return(site_domains_arel)
          site_domains_arel.should_receive(:build).
              with('domain' => 'usa.gov').
              and_return(site_domain)

          site_domain.should_receive(:save).and_return(true)
          site.should_receive(:normalize_site_domains)
          site.should_receive(:assign_sitelink_generator_names!)

          post :create,
               site_id: site.id,
               site_domain: { domain: 'usa.gov',
                              not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:site_domain).with(site_domain) }
        it { should redirect_to site_domains_path(site) }
        it { should set_the_flash.to('You have added usa.gov to this site.') }
      end

      context 'when domain params are not valid' do
        let(:site_domain) { mock_model(SiteDomain) }

        before do
          site_domains_arel = mock('site domains arel')
          site.stub(:site_domains).and_return(site_domains_arel)
          site_domains_arel.should_receive(:build).
              with('domain' => 'gov').
              and_return(site_domain)

          site_domain.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               site_domain: { domain: 'gov',
                              not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:site_domain).with(site_domain) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are not valid' do
        let(:site_domain) { mock_model(SiteDomain) }

        before do
          site_domains_arel = mock('site domains arel')
          site.stub(:site_domains).and_return(site_domains_arel)
          site_domains_arel.should_receive(:find_by_id).with('100').
            and_return(site_domain)

          site_domain.should_receive(:update_attributes).
              with('domain' => 'gov').
              and_return(false)

          put :update,
               site_id: site.id,
               id: 100,
               site_domain: { domain: 'gov',
                              not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:site_domain).with(site_domain) }
        it { should render_template(:edit) }
      end
    end
  end
end

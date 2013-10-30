require 'spec_helper'

describe Sites::DomainsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:domains) { mock('domains') }

      before do
        site.should_receive(:site_domains).and_return(domains)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:domains).with(domains) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are valid' do
        let(:domain) { mock_model(SiteDomain, domain: 'usa.gov') }

        before do
          site_domains = mock('site domains')
          site.stub(:site_domains).and_return(site_domains)
          site_domains.should_receive(:build).
              with('domain' => 'usa.gov').
              and_return(domain)

          domain.should_receive(:save).and_return(true)
          site.should_receive(:normalize_site_domains)

          post :create,
               site_id: site.id,
               domain: { domain: 'usa.gov', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:domain).with(domain) }
        it { should redirect_to site_domains_path(site) }
        it { should set_the_flash.to('You have added usa.gov to this site.') }
      end

      context 'when domain params are not valid' do
        let(:domain) { mock_model(SiteDomain) }

        before do
          site_domains = mock('site domains')
          site.stub(:site_domains).and_return(site_domains)
          site_domains.should_receive(:build).
              with('domain' => 'gov').
              and_return(domain)

          domain.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               domain: { domain: 'gov', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:domain).with(domain) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are not valid' do
        let(:domain) { mock_model(SiteDomain) }

        before do
          site_domains = mock('site domains')
          site.stub(:site_domains).and_return(site_domains)
          site_domains.should_receive(:find_by_id).with('100').and_return(domain)

          domain.should_receive(:update_attributes).
              with('domain' => 'gov').
              and_return(false)

          put :update,
               site_id: site.id,
               id: 100,
               domain: { domain: 'gov', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:domain).with(domain) }
        it { should render_template(:edit) }
      end
    end
  end
end

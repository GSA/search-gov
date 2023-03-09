require 'spec_helper'

describe Sites::SiteDomainsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:site_domains) { double('domains') }

      before do
        expect(site).to receive(:site_domains).and_return(site_domains)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:site_domains).with(site_domains) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are valid' do
        let(:site_domain) { mock_model(SiteDomain, domain: 'usa.gov') }

        before do
          site_domains_arel = double('site domains arel')
          allow(site).to receive(:site_domains).and_return(site_domains_arel)
          expect(site_domains_arel).to receive(:build).
            with({ 'domain' => 'usa.gov' }).
            and_return(site_domain)

          expect(site_domain).to receive(:save).and_return(true)
          expect(site).to receive(:normalize_site_domains)

          post :create,
               params: {
                 site_id: site.id,
                 site_domain: { domain: 'usa.gov',
                                not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:site_domain).with(site_domain) }
        it { is_expected.to redirect_to site_domains_path(site) }
        it { is_expected.to set_flash.to('You have added usa.gov to this site.') }
      end

      context 'when domain params are not valid' do
        let(:site_domain) { mock_model(SiteDomain) }

        before do
          site_domains_arel = double('site domains arel')
          allow(site).to receive(:site_domains).and_return(site_domains_arel)
          expect(site_domains_arel).to receive(:build).
            with({ 'domain' => 'gov' }).
            and_return(site_domain)

          expect(site_domain).to receive(:save).and_return(false)

          post :create,
               params: {
                 site_id: site.id,
                 site_domain: { domain: 'gov',
                                not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:site_domain).with(site_domain) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when domain params are not valid' do
        let(:site_domain) { mock_model(SiteDomain) }

        before do
          site_domains_arel = double('site domains arel')
          allow(site).to receive(:site_domains).and_return(site_domains_arel)
          expect(site_domains_arel).to receive(:find_by_id).with('100').
            and_return(site_domain)

          expect(site_domain).to receive(:update).
            with({ 'domain' => 'gov' }).
            and_return(false)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                site_domain: { domain: 'gov',
                               not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:site_domain).with(site_domain) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end
end

require 'spec_helper'

describe Sites::SitesController do
  fixtures :users, :affiliates, :memberships, :languages
  before { activate_authlogic }

  describe 'includes the correct concerns' do
    it { expect(controller.class.ancestors.include?(Accountable)).to eq(true) }
  end

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, id: 100

    it_behaves_like 'require complete account', :get, :index, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in'

      context 'when the site is no longer accessible' do
        let(:site) { mock_model(Affiliate) }

        before do
          allow(current_user).to receive_message_chain(:affiliates, :exists?).and_return(false)
          allow(current_user).to receive_message_chain(:affiliates, :first).and_return(site)
          get :index
        end

        it { is_expected.to redirect_to(site_path(site)) }
      end
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in'

      context 'when the site exists' do
        let(:site) { mock_model(Affiliate) }

        before do
          expect(current_user).to receive(:default_affiliate).twice.and_return(site)
          get :index
        end

        it { is_expected.to redirect_to(site_path(site)) }
      end

      context 'when the site does not exist' do
        let(:site) { mock_model(Affiliate) }

        before do
          expect(current_user).to receive(:default_affiliate).and_return(nil)
          allow(current_user).to receive_message_chain(:affiliates, :first).and_return(site)
          get :index
        end

        it { is_expected.to redirect_to(site_path(site)) }
      end
    end
  end

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :show, params: { id: site.id } }

      it { is_expected.to assign_to(:site).with(site) }
    end

    context 'when logged in as affiliate and when the site is no longer accessible' do
      include_context 'approved user logged in'

      before { get :show, params: { id: -1 } }

      it { is_expected.to redirect_to(sites_path) }
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in to a site'

      before { get :show, params: { id: site.id } }

      it { is_expected.to assign_to(:site).with(site) }
    end

    context 'when logged in as super admin and when the site is no longer accessible' do
      include_context 'super admin logged in'

      before { get :show, params: { id: -1 } }

      it { is_expected.to redirect_to(sites_path) }
    end

    context 'when affiliate is looking at dashboard data' do
      include_context 'approved user logged in to a site'

      let(:dashboard) { double('RtuDashboard') }

      before do
        expect(RtuDashboard).to receive(:new).with(site, Date.current, current_user.sees_filtered_totals).and_return dashboard
        get :show, params: { id: site.id }
      end

      it { is_expected.to assign_to(:dashboard).with(dashboard) }
    end
  end

  describe "#create" do
    it_should_behave_like 'restricted to approved user', :post, :create, id: 100

    context "when logged in" do
      include_context 'approved user logged in to a site'

      context "when the affiliate saves successfully" do
        let(:site) { mock_model(Affiliate, :users => []) }
        let(:emailer) { double(Emailer, :deliver_now => true) }

        before do
          expect(Affiliate).to receive(:new).with(
              'display_name' => 'New Aff',
              'locale' => 'es',
              'name' => 'newaff',
              'site_domains_attributes' => { '0' => { 'domain' => 'http://www.brandnew.gov' } }).and_return(site)
          expect(site).to receive(:save).and_return(true)
          expect(site).to receive(:push_staged_changes)
          expect(site).to receive(:assign_sitelink_generator_names!)

          autodiscoverer = double(SiteAutodiscoverer)
          expect(SiteAutodiscoverer).to receive(:new).with(site).and_return(autodiscoverer)
          expect(autodiscoverer).to receive(:run)

          expect(Emailer).to receive(:new_affiliate_site).and_return(emailer)
          post :create,
               params: {
                 site: { display_name: 'New Aff',
                         locale: 'es',
                         name: 'newaff',
                         site_domains_attributes: {
                           '0': { domain: 'http://www.brandnew.gov' }
                         } }
               }
        end

        it { is_expected.to redirect_to(site_path(site)) }

        it 'should add current user as a site user' do
          expect(site.users).to include(current_user)
        end
      end
    end
  end

  describe '#pin' do
    it_should_behave_like 'restricted to approved user', :put, :pin, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        request.env['HTTP_REFERER'] = site_path(site)
        expect(current_user).to receive(:update_attributes!).with(default_affiliate: site)
        put :pin, params: { id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to redirect_to(site_path(site)) }
      it { is_expected.to set_flash.to('You have set NPS Site as your default site.') }
    end
  end

  describe "#destroy" do
    it_should_behave_like 'restricted to approved user', :delete, :destroy, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      it 'should enqueue destruction of affiliate' do
        expect(Resque).to receive(:enqueue_with_priority).with(:low, SiteDestroyer, site.id)
        delete :destroy, params: { id: site.id }
      end

      it 'deactivates the site' do
        expect(site).to receive(:update_attributes!).with(active: false)
        expect(site).to receive(:user_ids=).with([])
        delete :destroy, params: { id: site.id }
      end

      context 'when successful' do
        before do
          delete :destroy, params: { id: site.id }
        end

        it { is_expected.to redirect_to(new_site_path) }
        it { is_expected.to set_flash.to("Scheduled site '#{site.display_name}' for deletion. This could take several hours to complete.") }
      end
    end
  end
end

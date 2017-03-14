require 'spec_helper'

describe Sites::SitesController do
  fixtures :users, :affiliates, :memberships, :languages
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in'

      context 'when the site is no longer accessible' do
        let(:site) { mock_model(Affiliate) }

        before do
          current_user.stub_chain(:affiliates, :exists?).and_return(false)
          current_user.stub_chain(:affiliates, :first).and_return(site)
          get :index
        end

        it { should redirect_to(site_path(site)) }
      end
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in'

      context 'when the site exists' do
        let(:site) { mock_model(Affiliate) }

        before do
          current_user.should_receive(:default_affiliate).twice.and_return(site)
          get :index
        end

        it { should redirect_to(site_path(site)) }
      end

      context 'when the site does not exist' do
        let(:site) { mock_model(Affiliate) }

        before do
          current_user.should_receive(:default_affiliate).and_return(nil)
          current_user.stub_chain(:affiliates, :first).and_return(site)
          get :index
        end

        it { should redirect_to(site_path(site)) }
      end
    end
  end

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :show, id: site.id }

      it { should assign_to(:site).with(site) }
    end

    context 'when logged in as affiliate and when the site is no longer accessible' do
      include_context 'approved user logged in'

      before { get :show, id: -1 }

      it { should redirect_to(sites_path) }
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in to a site'

      before { get :show, id: site.id }

      it { should assign_to(:site).with(site) }
    end

    context 'when logged in as super admin and when the site is no longer accessible' do
      include_context 'super admin logged in'

      before { get :show, id: -1 }

      it { should redirect_to(sites_path) }
    end

    context 'when affiliate is looking at dashboard data' do
      include_context 'approved user logged in to a site'

      let(:dashboard) { double('RtuDashboard') }

      before do
        RtuDashboard.should_receive(:new).with(site, Date.current, current_user.sees_filtered_totals).and_return dashboard
        get :show, id: site.id
      end

      it { should assign_to(:dashboard).with(dashboard) }
    end
  end

  describe "#create" do
    it_should_behave_like 'restricted to approved user', :post, :create

    context "when logged in" do
      include_context 'approved user logged in to a site'

      context "when the affiliate saves successfully" do
        let(:site) { mock_model(Affiliate, :users => []) }
        let(:emailer) { double(Emailer, :deliver => true) }

        before do
          Affiliate.should_receive(:new).with(
              'display_name' => 'New Aff',
              'locale' => 'es',
              'name' => 'newaff',
              'site_domains_attributes' => { '0' => { 'domain' => 'http://www.brandnew.gov' } }).and_return(site)
          site.should_receive(:save).and_return(true)
          site.should_receive(:push_staged_changes)
          site.should_receive(:assign_sitelink_generator_names!)

          autodiscoverer = double(SiteAutodiscoverer)
          SiteAutodiscoverer.should_receive(:new).with(site).and_return(autodiscoverer)
          autodiscoverer.should_receive(:run)

          adapter = double(NutshellAdapter)
          NutshellAdapter.should_receive(:new).and_return(adapter)
          adapter.should_receive(:push_site).with(site)

          Emailer.should_receive(:new_affiliate_site).and_return(emailer)
          post :create,
               site: { display_name: 'New Aff',
                       locale: 'es',
                       name: 'newaff',
                       site_domains_attributes: { '0' => { domain: 'http://www.brandnew.gov' } },}
        end

        it { should redirect_to(site_path(site)) }

        it 'should add current user as a site user' do
          site.users.should include(current_user)
        end
      end
    end
  end

  describe '#pin' do
    it_should_behave_like 'restricted to approved user', :put, :pin

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        request.env['HTTP_REFERER'] = site_path(site)
        current_user.should_receive(:update_attributes!).with(default_affiliate: site)
        put :pin, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should redirect_to(site_path(site)) }
      it { should set_flash.to('You have set NPS Site as your default site.') }
    end
  end

  describe "#destroy" do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        adapter = double(NutshellAdapter)
        NutshellAdapter.should_receive(:new).and_return(adapter)
        adapter.should_receive(:push_site).with(site)
      end

      it 'should enqueue destruction of affiliate' do
        Resque.should_receive(:enqueue_with_priority).with(:low, SiteDestroyer, site.id)
        delete :destroy, id: site.id
      end

      it 'deactivates the site' do
        site.should_receive(:update_attributes!).with(active: false)
        site.should_receive(:user_ids=).with([])
        delete :destroy, id: site.id
      end

      context 'when successful' do
        before do
          delete :destroy, id: site.id
        end

        it { should redirect_to(new_site_path) }
        it { should set_flash.to("Scheduled site '#{site.display_name}' for deletion. This could take several hours to complete.") }
      end
    end
  end
end

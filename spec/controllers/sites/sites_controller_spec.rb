require 'spec_helper'

describe Sites::SitesController do
  fixtures :users, :affiliates
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

      let(:dashboard) { double('Dashboard') }

      before do
        Dashboard.should_receive(:new).with(site).and_return dashboard
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
        let(:emailer) { mock(Emailer, :deliver => true) }

        before do
          Affiliate.should_receive(:new).with("site_domains_attributes" => {"0" => {"domain" => "http://www.brandnew.gov"}},
                                              "display_name" => "New Aff", "locale" => "es").and_return(site)
          site.should_receive(:name=).with('newaff')
          site.should_receive(:save).and_return(true)
          site.should_receive(:push_staged_changes)
          Emailer.should_receive(:new_affiliate_site).and_return(emailer)
          post :create, affiliate: {site_domains_attributes: {"0" => {domain: "http://www.brandnew.gov"}},
                                    display_name: "New Aff", name: "newaff", locale: "es"}
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
      it { should set_the_flash.to('You have set NPS Site as your default site.') }
    end
  end
end

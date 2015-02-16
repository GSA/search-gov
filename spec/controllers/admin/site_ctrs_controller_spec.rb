require 'spec_helper'

describe Admin::SiteCtrsController do
  fixtures :users, :search_modules
  let(:site_ctr) { mock(SiteCtr, site_ctrs: %w(first second)) }
  let(:search_module) { search_modules(:boos) }

  before do
    activate_authlogic
    SiteCtr.stub(:new).with(instance_of(Fixnum), 'BOOS').and_return site_ctr
  end

  describe "GET 'show'" do

    context "when not logged in" do
      it "should redirect to the home page" do
        get :show, module_tag: 'BOOS'
        response.should redirect_to login_path
      end
    end

    context "when logged in as an admin" do
      before do
        @user = users("affiliate_admin")
        UserSession.create(@user)
        get :show, module_tag: 'BOOS'
      end

      it "should allow the admin to see site CTRs for some search module" do
        response.should be_success
      end

      it { should assign_to(:site_ctrs).with(%w(first second)) }
      it { should assign_to(:search_module).with(search_module) }

    end
  end
end

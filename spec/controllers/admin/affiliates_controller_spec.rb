require 'spec_helper'

describe Admin::AffiliatesController do
  fixtures :users, :affiliates, :memberships, :statuses

  context "when logged in as a non-affiliate admin user" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("non_affiliate_admin").email, :password => "admin")
    end

    it "should redirect to the usasearch home page" do
      get :index
      response.should redirect_to(account_path)
    end
  end

  context "when not logged in" do
    it "should redirect to the login page" do
      get :index
      response.should redirect_to(login_path)
    end
  end

  describe "#analytics" do
    context "when logged in as an affiliate admin" do
      before do
        activate_authlogic
        UserSession.create(:email => users("affiliate_admin").email, :password => "admin")
        @affiliate = affiliates("basic_affiliate")
      end

      it "should redirect to the affiliate analytics page for the affiliate id passed" do
        get :analytics, :id => @affiliate.id
        response.should redirect_to new_site_queries_path(@affiliate)
      end
    end
  end

  describe "#edit" do
    context "When logged in as an affiliate admin" do
      render_views
      let(:affiliate) { affiliates("basic_affiliate") }

      before do
        activate_authlogic
        UserSession.create(:email => users("affiliate_admin").email, :password => "admin")
        get :edit, :id => affiliate.id
      end

      it { should respond_with :success }
    end
  end

  describe '#update' do
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      activate_authlogic
      UserSession.create(email: users(:affiliate_admin).email, password: 'admin')
    end

    it 'triggers NutshellAdapter#push_site' do
      adapter = mock(NutshellAdapter)
      NutshellAdapter.stub(:new) { adapter }
      adapter.should_receive(:push_site).with(affiliate)

      put :update, id: affiliate.id, record: {}
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoostedSitesUploadsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for #new" do
        get :new, :affiliate_id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :new, :affiliate_id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who owns the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :new, :affiliate_id => affiliates(:power_affiliate).id
      end

      should_render_template 'boosted_sites_uploads/new.html.haml', :layout => 'account'
    end
  end

  describe "do POST on #create" do
    it "should require affiliate login for create" do
      post :create, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end
  end

end

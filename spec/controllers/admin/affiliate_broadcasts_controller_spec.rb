require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AffiliateBroadcastsController do
  fixtures :users
  integrate_views

  before do
    activate_authlogic
  end

  it "should require login" do
    get :new
    response.should redirect_to(new_user_session_path)
  end

  context "a logged in user" do
    before do
      @user = users(:affiliate_admin)
      UserSession.create(@user)
    end

    describe "GET new" do
      it "should assign a new affiliate broadcast" do
        get :new
        assigns[:affiliate_broadcast].should_not be_nil
        assigns[:page_title].should == "Affiliate Broadcast"
      end
    end

    describe "POST create" do
      it "should create a new AffiliateBroadcast" do
        post :create, :affiliate_broadcast => {:subject => "AAAAA", :body=> "BBBBB"}
        AffiliateBroadcast.find_by_user_id_and_subject_and_body(@user.id, "AAAAA", "BBBBB").should_not be_nil
      end

      it "should redirect to the affiliate admin page with a flash message on success" do
        post :create, :affiliate_broadcast => {:subject => "AAAAA", :body=> "BBBBB"}
        response.should redirect_to(admin_affiliates_path)
        flash[:success].should_not be_nil
      end

      it "should render #new on errors" do
        post :create, :affiliate_broadcast => {:subject => "AAAAA"}
        response.should render_template(:new)
        assigns[:page_title].should == "Affiliate Broadcast"
      end
    end
  end
end

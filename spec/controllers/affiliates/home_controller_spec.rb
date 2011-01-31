require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::HomeController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #index" do
    it "should not require affiliate login" do
      get :index
      response.should be_success
    end
  end
  
  describe "do GET on #how_it_works" do
    it "should have a title" do
      get :how_it_works
      response.should be_success
    end
  end
  
  describe "do GET on #demo" do
    it "should have a title" do
      get :demo
      response.should be_success
    end

    it "assigns @affiliate_ads that contains 3 items" do
      get :demo
      assigns[:affiliate_ads].size.should == 3
    end

    it "assigns @affiliate_ads that contains more than 3 items if all parameter is defined" do
      get :demo, :all => ""
      assigns[:affiliate_ads].size.should > 3
    end
  end

  describe "do GET on #edit" do
    it "should require affiliate login for edit" do
      get :edit, :id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for edit" do
        get :edit, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      integrate_views
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should render the edit page" do
        get :edit, :id => affiliates(:basic_affiliate).id
        response.should render_template("edit")
      end

    end
  end

  describe "do POST on #update" do
    it "should require affiliate login for update" do
      post :update, :id => affiliates(:power_affiliate).id, :affiliate=> {}
      response.should redirect_to(login_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        @affiliate = user.affiliates.first
      end

      it "should update the Affiliate" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"newname", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        @affiliate.reload
        @affiliate.name.should == "newname"
        @affiliate.footer.should == "BAR"
        @affiliate.header.should == "FOO"
        @affiliate.domains.should == "BLAT"
      end

      it "should redirect to affiliates home on success with flash message" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"newname", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should redirect_to(home_affiliates_path(:said=>@affiliate.id))
        flash[:success].should_not be_nil
      end

      it "should render edit on failure" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should render_template(:edit)
      end
    end
  end
end

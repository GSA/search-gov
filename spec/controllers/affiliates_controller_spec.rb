require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliatesController do
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

  describe "do GET on #edit" do
    it "should require affiliate login for edit" do
      get :edit, :id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
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
  end

  describe "do POST on #update" do
    it "should require affiliate login for update" do
      post :update, :id => affiliates(:power_affiliate).id, :affiliate=> {}
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        @affiliate = user.affiliates.first
      end

      it "should update the Affiliate" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"NEWNAME", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        @affiliate.reload
        @affiliate.name.should == "NEWNAME"
        @affiliate.footer.should == "BAR"
        @affiliate.header.should == "FOO"
        @affiliate.domains.should == "BLAT"
      end

      it "should redirect to account page on success with flash message" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"NEWNAME", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should redirect_to(account_path)
        flash[:success].should == "Updated your affiliate successfully."
      end

      it "should render edit on failure" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should render_template(:edit)
      end
    end
  end

end

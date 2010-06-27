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

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit, :id => affiliates(:another_affiliate).id
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
        flash[:success].should_not be_nil
      end

      it "should render edit on failure" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should render_template(:edit)
      end
    end
  end
  
  describe "#analytics" do
    context "when requesting analytics for an affiliate" do
      before do
        @affiliate = affiliates("basic_affiliate")
      end
      
      context "when not logged in" do
        it "should redirect to the home page" do
          get :analytics, :id => @affiliate.id
          response.should redirect_to new_user_session_path
        end
      end
      
      context "when logged in as a user that is neither an affiliate or an admin" do
        before do
          @user = users("non_affiliate_admin")
          UserSession.create(@user)
        end
        
        it "should redirect to the home page" do
          get :analytics, :id => @affiliate.id
          response.should redirect_to(home_page_path)
        end
      end
      
      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          UserSession.create(@user)
          @admin_affiliate = affiliates("admin_affiliate")
        end
        
        it "should allow the admin to view analytics for his own affiliate" do
          get :analytics, :id => @admin_affiliate.id
          response.should be_success
        end
        
        it "should allow the admin to view analytics for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :analytics, :id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end
      
      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end
        
        it "should allow the affiliate to view his own analytics" do
          get :analytics, :id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
        
        it "should not allow the affiliate to view analytics for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :analytics, :id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end
      end 
    end
  end
  
  describe "#monthly_reports" do
    context "when requesting monthly reports for an affiliate" do
      before do
        @affiliate = affiliates("basic_affiliate")
      end
      
      context "when not logged in" do
        it "should redirect to the home page" do
          get :monthly_reports, :id => @affiliate.id
          response.should redirect_to new_user_session_path
        end
      end
      
      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          UserSession.create(@user)
        end
        
        it "should allow the admin to view monthly reports for his own affiliate" do
          get :monthly_reports, :id => @user.affiliates.first.id
          response.should be_success
        end
        
        it "should allow the admin to view monthly reports for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :monthly_reports, :id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end
      
      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end
        
        it "should allow the affiliate to view his own monthly reports" do
          get :monthly_reports, :id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
        
        it "should not allow the affiliate to view monthly reports for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :monthly_reports, :id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end
      end 
    end
  end

end

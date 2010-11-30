require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliateUsersController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
    @affiliate = affiliates(:basic_affiliate)
  end

  describe "#index" do
    context "when not logged in" do
      it "should redirect to the sign in page" do
        get :index, :affiliate_id => @affiliate.id
        response.should redirect_to(new_user_session_path)
      end
    end
    
    context "when logged in as the owner of an affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
      end
      
      it "should assign a nil email value, and show the page" do
        get :index, :affiliate_id => @affiliate.id
        assigns[:email].should be_nil
        response.should be_success
      end
    end
    
    context "when logged in as a user of an affiliate" do
      before do
        @another_user = users(:affiliate_manager_with_no_affiliates)
        @affiliate.users << @another_user
        UserSession.create(@another_user)
      end
      
      it "should show the index page" do
        get :index, :affiliate_id => @affiliate.id
        response.should be_success
      end
    end
    
    context "when logged in as a user that is not associated with an affiliate" do
      before do
        @another_user = users(:marilyn)
        UserSession.create(@marilyn)
      end
      
      it "should redirect back to the user's account page" do
        get :index, :affiliate_id => @affiliate.id
        response.should redirect_to new_user_session_path
      end
    end
  end
  
  describe "#create" do
    integrate_views
    context "when not logged in" do
      it "should redirect to the sign in page" do
        post :create, :affiliate_id => @affiliate.id, :email => 'newuser@usa.gov'
        response.should redirect_to(new_user_session_path)
      end
    end
    
    context "when logged in as the affiliate owner" do
      before do
        @user = users(:affiliate_manager)
        UserSession.create(@user)
      end
      
      context "when the user added is not an existing affiliate user" do
        it "should assign the email address and flash an error that the user is not recognized" do
          post :create, :affiliate_id => @affiliate.id, :email => 'newuser@usa.gov'
          assigns[:email].should == 'newuser@usa.gov'
          assigns[:user].should be_nil
          response.should contain(/Could not find user with email: newuser@usa.gov; please ask them to register as an affiliate with their email address./)
          response.should render_template(:index)
        end
      end
      
      context "when the user added is the owner of the affiliate" do
        it "should flash a message that the owner can not be added" do
          post :create, :affiliate_id => @affiliate.id, :email => @user.email
          assigns[:email].should == @user.email
          assigns[:user].should == @user
          response.should contain(/That user is the current owner of this affiliate; you can not add them again./)
          response.should render_template(:index)
        end
      end
      
      context "when the user added is already a user of the affiliate" do
        before do
          @another_user = users(:affiliate_manager_with_no_affiliates)
          @affiliate.users << @another_user
        end
        
        it "should flash a message the user is already assocaited with the affiliate" do
          post :create, :affiliate_id => @affiliate.id, :email => @another_user.email
          assigns[:email].should == @another_user.email
          assigns[:user].should == @another_user
          response.should contain(/That user is already associated with this affiliate; you can not add them again./)
          response.should render_template(:index)
        end
      end
      
      context "when the user is a valid user, but not associated with the affiliate" do
        before do
          @another_user = users(:marilyn)
        end
        
        it "should associate the user and flash a success message" do
          @affiliate.users.include?(@another_user).should be_false
          post :create, :affiliate_id => @affiliate.id, :email => @another_user.email
          assigns[:email].should be_nil
          assigns[:user].should == @another_user
          response.should render_template(:index)
          response.body.should contain(/Successfully added #{@another_user.contact_name} \(#{@another_user.email}\)/)
          @affiliate.users.include?(@another_user).should be_true
        end
      end
    end
  end

  describe "#destroy" do
    integrate_views
    before do
      @affiliate_user = users(:marilyn)
      @affiliate.users << @affiliate_user
    end
    
    context "when not logged in" do
      it "should redirect to the sign in page" do
        delete :destroy, :affiliate_id => @affiliate.id, :id => @affiliate_user.id
        response.should redirect_to(new_user_session_path)
        @affiliate.users.include?(@affiliate_user).should be_true
      end
    end
    
    context "when logged in as the owner of the affiliate" do
      before do
        @affiliate_owner = users(:affiliate_manager)
        UserSession.create(@affiliate_owner)
      end
      
      context "when attempting to remove an affiliate user that is not the owner" do
        it "should remove the user from the affiliate" do
          delete :destroy, :affiliate_id => @affiliate.id, :id => @affiliate_user.id
          response.should render_template(:index)
          @affiliate.users.include?(@affiliate_user).should be_false
        end
      end
      
      context "when attempting to remove an affiliate user that is the owner of the affiliate" do
        it "should not remove the user and flash an error message" do
          delete :destroy, :affiliate_id => @affiliate.id, :id => @affiliate_owner.id
          response.should contain(/You can't remove the owner of the affiliate from the list of users./)
          response.should render_template(:index)
          @affiliate.users.include?(@affiliate_owner).should be_true
        end
      end
    end
  end
end

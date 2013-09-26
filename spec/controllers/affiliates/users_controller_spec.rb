require 'spec_helper'

describe Affiliates::UsersController do
  fixtures :users, :affiliates, :memberships
  before do
    activate_authlogic
    @affiliate = affiliates(:basic_affiliate)
  end

  describe "#index" do
    context "when not logged in" do
      it "should redirect to the sign in page" do
        get :index, :affiliate_id => @affiliate.id
        response.should redirect_to(login_path)
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
        response.should redirect_to login_path
      end
    end
  end

  describe "#create" do
    render_views
    context "when not logged in" do
      it "should redirect to the sign in page" do
        post :create, :affiliate_id => @affiliate.id, :email => 'newuser@usa.gov'
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as an affiliate user" do
      before do
        @user = users(:affiliate_manager)
        UserSession.create(@user)
        @emailer = mock(Emailer)
        @emailer.stub!(:deliver).and_return true
      end

      context "when the user added is not an existing user" do
        it "should assign the email address and contact name, create a user with that information, and send a welcome email" do
          new_user = mock('user', :email => 'newuser@usa.gov', :contact_name => 'New User')
          User.should_receive(:new_invited_by_affiliate).and_return(new_user)
          new_user.should_receive(:save).and_return(true)
          post :create, :affiliate_id => @affiliate.id, :email => 'newuser@usa.gov', :name => 'New User'
          session[:flash][:success].should == "That user does not exist in the system. We've created a temporary account and notified them via email on how to login. Once they login, they will have access to the affiliate."
          response.should redirect_to affiliate_users_path(@affiliate)
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
          session[:flash][:error].should == "That user is already associated with this affiliate. You cannot add them again."
          response.should redirect_to affiliate_users_path(@affiliate)
        end
      end

      context "when the user is a valid user, but not associated with the affiliate" do
        before do
          @another_user = users(:marilyn)
        end

        it "should associate the user and flash a success message" do
          @affiliate.users.include?(@another_user).should be_false
          Emailer.should_receive(:new_affiliate_user).with(@affiliate, @another_user, @user).and_return @emailer
          post :create, :affiliate_id => @affiliate.id, :email => @another_user.email
          assigns[:email].should be_nil
          assigns[:user].should == @another_user
          session[:flash][:success].should == "Successfully added #{@another_user.contact_name} (#{@another_user.email})"
          response.should redirect_to affiliate_users_path(@affiliate)
          @affiliate.users.include?(@another_user).should be_true
        end
      end

      context "when the new user name or email is blank" do
        before do
          @user = users(:affiliate_manager)
          UserSession.create(@user)
        end

        it "sets flash[:error] message" do
          post :create, :affiliate_id => @affiliate.id, :email => "", :name => ""
          flash[:success].should be_blank
        end

      end

    end
  end

  describe "#destroy" do
    render_views
    before do
      @another_affiliate_user = users(:marilyn)
      @affiliate.users << @another_affiliate_user
    end

    context "when not logged in" do
      it "should redirect to the sign in page" do
        delete :destroy, :affiliate_id => @affiliate.id, :id => @another_affiliate_user.id
        response.should redirect_to(login_path)
        @affiliate.users.include?(@another_affiliate_user).should be_true
      end
    end

    context "when logged in as a user of the affiliate" do
      before do
        @user = users(:affiliate_manager)
        UserSession.create(@user)
        @affiliate.users.include?(@user).should be_true
      end

      context "when attempting to remove oneself from the affiliate" do
        it "should remove the user and redirect back to the affiliates home" do
          delete :destroy, :affiliate_id => @affiliate.id, :id => @user.id
          response.should redirect_to home_affiliates_path
          @affiliate.users.include?(@user).should be_false
        end
      end

      context "when attempting to remove an affiliate user" do
        it "should remove the user from the affiliate" do
          delete :destroy, :affiliate_id => @affiliate.id, :id => @another_affiliate_user
          response.should redirect_to affiliate_users_path(@affiliate)
          @affiliate.users.include?(@another_affiliate_user).should be_false
        end
      end
    end
  end
end

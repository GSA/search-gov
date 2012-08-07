require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  describe "do GET on new" do
    it "should assign @user" do
      user = mock_model(User)
      User.should_receive(:new).and_return(user)
      get :new
      assigns[:user].should == user
    end
  end

  describe "do POST on create" do
    context "when the user session fails to save" do
      it "should assign @user" do
        user = mock_model(User)
        User.should_receive(:new).and_return(user)
        post :create, :user_session => {:email => "invalid@fixtures.org", :password => "admin"}
        assigns[:user].should == user
      end
    end
  end

  describe "do POST on create for affiliate admin" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("affiliate_admin").email, :password => "admin"}
      response.should redirect_to(home_affiliates_url)
    end
  end

  describe "do POST on create for affiliate manager" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("affiliate_manager").email, :password => "admin"}
      response.should redirect_to(home_affiliates_url)
    end
  end

   describe "do POST on create for developer" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("developer").email, :password => "admin"}
      response.should redirect_to(developer_redirect_url)
    end
  end
end

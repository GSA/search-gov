require "#{File.dirname(__FILE__)}/../spec_helper"

describe UserSessionsController do
  fixtures :users

  describe "do POST on create for analyst" do
    it "should redirect to analytics homepage" do
      post :create, :user_session => {:email => users("analyst").email, :password => "admin"}
      response.should redirect_to(analytics_home_page_url)
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
end

require "#{File.dirname(__FILE__)}/../spec_helper"

describe DevelopersController do
  describe "#new" do
    it "should instantiate a User with only developer privileges" do
      get :new
      assigns[:user].is_affiliate_or_higher.should be_false
    end
  end
  
  describe "#create" do    
    it "should create a User with the passed parameters, with developer privileges" do
      post :create, :user => { :email => 'a.user@gmail.com', :contact_name => 'A User', :password => 'password', :password_confirmation => 'password' }
      assigns[:user].should_not be_nil
      assigns[:user].is_affiliate_or_higher.should be_false
      assigns[:user].id.should_not be_nil
      flash[:success].should == "Thank you for registering for USA.gov Search Services"
      response.should redirect_to(account_path)
    end
    
    it "should redirect to the new form page if the save fails" do
      post :create, :user => { :email => 'a.user.gmail.com' }
      assigns[:user].should_not be_nil
      response.should render_template(:new)
    end
  end
end
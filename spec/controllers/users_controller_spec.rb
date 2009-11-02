require "#{File.dirname(__FILE__)}/../spec_helper"

describe UsersController do
  fixtures :users

  context "when logged in" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("affiliate_admin").email, :password => "admin")
    end

    describe "do GET on show" do
      it "should assign the user" do
        get :show
        assigns[:user].should be_instance_of(User)
      end
    end

    describe "do GET on edit" do
      it "should assign the user" do
        get :edit
        assigns[:user].should be_instance_of(User)
      end
    end

    describe "do POST on update" do
      it "should assign the user" do
        post :update, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        assigns[:user].should be_instance_of(User)
      end

      it "should update the user record" do
        post :update, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        User.find_by_email("changed@foo.com").time_zone.should == "UTC"
      end

      it "should redirect to account page on success with flash message" do
        post :update, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        response.should redirect_to(account_url)
        flash[:success].should == "Account updated!"
      end

      it "should render edit on failure" do
        post :update, :user => {:email => "changed@foo.com", :time_zone => "UTC", :password=>"not", :password_confirmation => "the same"}
        response.should render_template(:edit)
      end
    end
  end
end
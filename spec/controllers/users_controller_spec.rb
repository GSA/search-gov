require "#{File.dirname(__FILE__)}/../spec_helper"

describe UsersController do
  fixtures :users

  context "when logged in" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("non_affiliate_admin").email, :password => "admin")
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
        post :update, :user => {:email => "changed@foo.com", :time_zone => "FOO", :contact_name => "BAR"}
        user = User.find_by_email("changed@foo.com")
        user.time_zone.should == "FOO"
        user.contact_name.should == "BAR"
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

      it "should not allow a user to promote themselves to affiliate admin privileges" do
        users("non_affiliate_admin").is_affiliate_admin.should be_false
        post :update, :user => {:email => "changed@foo.com", :is_affiliate_admin => true}
        User.find_by_email("changed@foo.com").is_affiliate_admin.should be_false
      end

      it "should not allow a user to promote themselves to affiliate" do
        users("non_affiliate_admin").is_affiliate.should be_false
        post :update, :user => {:email => "changed@foo.com", :is_affiliate => true}
        User.find_by_email("changed@foo.com").is_affiliate.should be_false
      end
    end
  end
end
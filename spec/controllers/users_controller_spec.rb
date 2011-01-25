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

  context "when not logged in" do
    before do
      @affiliate_user_attributes = {
          :contact_name => "Some One",
          :email => "unique_login@agency.gov",
          :password => "password",
          :password_confirmation => "password",
          :is_affiliate => "1"
      }
    end

    describe "do POST on create" do
      before do
        @user = stub_model(User, @affiliate_user_attributes)
        User.should_receive(:new_affiliate_or_developer).and_return(@user)
      end

      it "should assign @user" do
        @user.should_receive(:save)
        post :create, :user => @affiliate_user_attributes
        assigns[:user].should == @user
      end

      context "when the user fails to save" do
        before do
          @user.should_receive(:save).and_return(false)
        end

        it "should render login page on failure" do
          post :create
          response.should render_template("user_sessions/new")
        end

        it "should assign @user_session on failure" do
          post :create
          assigns[:user_session].should be_instance_of(UserSession)
        end
      end
    end

  end
end

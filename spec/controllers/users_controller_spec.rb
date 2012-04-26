require 'spec/spec_helper'

describe UsersController do
  fixtures :users

  context "when logged in as an affiliate" do
    before do
      activate_authlogic
      @user = users('affiliate_manager')
      UserSession.create(:email=> @user.email, :password => "admin")
    end

    describe "do GET on show" do
      it "should assign the user" do
        get :show, :id => @user.id
        assigns[:user].should be_instance_of(User)
      end
    end

    describe "do GET on edit" do
      it "should assign the user" do
        get :edit, :id => @user.id
        assigns[:user].should be_instance_of(User)
      end
    end

    describe "do POST on update" do
      it "should assign the user" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        assigns[:user].should be_instance_of(User)
      end

      it "should update the user record" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :time_zone => "FOO", :contact_name => "BAR"}
        user = User.find_by_email("changed@foo.com")
        user.time_zone.should == "FOO"
        user.contact_name.should == "BAR"
      end

      it "should redirect to account page on success with flash message" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        response.should redirect_to(account_url)
        flash[:success].should == "Account updated!"
      end

      it "should render edit on failure" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :time_zone => "UTC", :password=>"not", :password_confirmation => "the same"}
        response.should render_template(:edit)
      end

      it "should not allow a user to promote themselves to affiliate admin privileges" do
        users("affiliate_manager").is_affiliate_admin.should be_false
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :is_affiliate_admin => true}
        User.find_by_email("changed@foo.com").is_affiliate_admin.should be_false
      end
    end
  end

  context "when logged in as a developer" do
    before do
      activate_authlogic
      @user = users('non_affiliate_admin')
      UserSession.create(:email=> @user.email, :password => "admin")
    end

    describe "do GET on show" do
      it "should redirect the developer to the USA.gov developer page" do
        get :show, :id => @user.id
        response.should redirect_to(developer_redirect_url)
      end
    end

    describe "do GET on edit" do
      it "should redirect the developer to the USA.gov developer page" do
        get :edit, :id => @user.id
        response.should redirect_to(developer_redirect_url)
      end
    end

    describe "do POST on update" do
      it "should redirect the developer to the USA.gov developer page" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com", :time_zone => "UTC"}
        response.should redirect_to(developer_redirect_url)
      end
    end
  end

  context "when not logged in" do
    describe "do POST on create" do
      before do
        @user = stub_model(User)
        User.should_receive(:new).and_return(@user)
      end

      it "should assign @user" do
        @user.should_receive(:save)
        post :create
        assigns[:user].should == @user
      end

      context "when a user saves successfully" do
        before do
          @user.should_receive(:save).and_return(true)
        end

        it "should redirect to affiliate home for affiliate user" do
          @user.should_receive(:is_affiliate?).twice.and_return(true)
          post :create
          response.should redirect_to(home_affiliates_path)
        end

        it "should redirect to my account page for non affiliate user" do
          @user.should_receive(:is_affiliate?).twice.and_return(false)
          post :create
          response.should redirect_to(account_path)
        end
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

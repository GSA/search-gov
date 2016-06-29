require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { should use_before_filter(:reset_session) }

  describe "do GET on new" do
    it "should assign @user" do
      user = mock_model(User)
      User.should_receive(:new).and_return(user)
      get :new
      assigns[:user].should == user
    end
  end

  describe "do POST on create" do
    context 'when the user is not approved' do
      before do
        post :create, user_session: { email: 'affiliate_manager_with_not_approved_status@fixtures.org',
                                      password: '' }
      end

      it { should redirect_to 'http://www.usa.gov' }
    end

    context "when the user session fails to save" do
      it "should assign @user" do
        user = mock_model(User)
        User.should_receive(:new).and_return(user)
        post :create, :user_session => {:email => "invalid@fixtures.org", :password => "admin"}
        assigns[:user].should == user
      end
    end
  end

  describe "do POST on create for developer" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("developer").email, :password => "admin"}
      response.should redirect_to(developer_redirect_url)
    end
  end
end

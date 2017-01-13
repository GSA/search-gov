require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { should use_before_filter(:reset_session) }
  it { should use_before_filter(:require_password_reset) }

  describe '#new' do
    before { get :new }
    it { should render_template(:new) }
  end

  describe "#create" do
    let(:post_create) do
      post :create, user_session: { email: user.email , password: user.password }
    end

    context 'when the user is not approved' do
      let(:user) { users(:affiliate_manager_with_not_approved_status) }
      before { post_create }

      it { should redirect_to 'https://www.usa.gov' }
    end

    context "when the user session fails to save" do
      before do
        post :create, :user_session => {:email => "invalid@fixtures.org", :password => "admin"}
      end

      it { should render_template(:new) }
    end

    context "when the user's password needs to be reset" do
      let(:user) do
        mock_model(User, requires_password_reset?: true, email: 'foo@bar.com', password: 'test1234!')
      end

      before do
        User.should_receive(:find_by_email).with(user.email).and_return user
        user.should_receive(:deliver_password_reset_instructions!).and_return(true)
        post_create
      end

      it { should redirect_to(login_path) }
      it { should set_flash[:notice].to /Looks like it's time to change your password!/ }
    end
  end

  describe "do POST on create for developer" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("developer").email, :password => "test1234!"}
      response.should redirect_to(developer_redirect_url)
    end
  end
end

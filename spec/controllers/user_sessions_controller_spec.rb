require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { is_expected.to use_before_filter(:reset_session) }

  describe '#new' do
    before { get :new }
    it { is_expected.to render_template(:new) }
  end

  describe "#create" do
    let(:user) { users(:affiliate_manager) }
    let(:post_create) do
      post :create, user_session: { email: user.email, password: user.password }
    end

    it 'filters passwords in the logfile' do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).
        with(/ \"password\"=>\"\[FILTERED\]\"/)
      post_create
    end

    context 'when the user is not approved' do
      let(:user) { users(:affiliate_manager_with_not_approved_status) }
      before { post_create }

      it { is_expected.to render_template(:new) }
    end

    context "when the user session fails to save" do
      before do
        post :create, :user_session => {:email => "invalid@fixtures.org", :password => "admin"}
      end

      it { is_expected.to render_template(:new) }
    end
  end

  describe "do POST on create for developer" do
    it "should redirect to affiliate home page" do
      post :create, :user_session => {:email => users("developer").email, :password => "test1234!"}
      expect(response).to redirect_to(developer_redirect_url)
    end
  end
end

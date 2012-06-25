require 'spec/spec_helper'

describe Affiliates::ApiController do
  fixtures :affiliates, :users

  before do
    activate_authlogic
  end

  describe "#index" do
    render_views
    before do
      @user = users(:affiliate_manager)
      UserSession.create(@user)
      @affiliate = affiliates(:basic_affiliate)
    end

    it "should render successfully and display both the affiliate name and the user's api key" do
      get :index, :affiliate_id => @affiliate.id
      response.should be_success

      response.body.should contain(@user.api_key)
      response.body.should contain(@affiliate.name)
    end
  end

end

require 'spec/spec_helper'

describe "affiliates/users/index.html.haml" do
  fixtures :affiliates, :users
  before do
    activate_authlogic
    assigns[:affiliate] = @affiliate = affiliates(:basic_affiliate)
    @affiliate_user     = users(:another_affiliate_manager)
    @affiliate.users << @affiliate_user
  end

  context "when affiliate user" do
    before do
      UserSession.create(@affiliate_user)
      view.stub!(:current_user).and_return @affiliate_user
    end
    
    it "should not show the make owner action" do
      assign(:affiliate_id, @affiliate.to_param)
      render
    end
  end
end

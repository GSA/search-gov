require "#{File.dirname(__FILE__)}/../../../spec_helper"

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
    end
    
    it "should not show the make owner action" do
      render :path_parameters => {:affiliate_id => @affiliate.to_param}
    end
  end
end

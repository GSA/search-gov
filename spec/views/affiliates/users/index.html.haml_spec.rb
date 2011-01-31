require "#{File.dirname(__FILE__)}/../../../spec_helper"
describe "affiliates/users/index.html.haml" do
  fixtures :affiliates, :users
  before do
    activate_authlogic
    assigns[:affiliate] = @affiliate = affiliates(:basic_affiliate)
    @owner              = @affiliate.owner
    @affiliate_user     = users(:another_affiliate_manager)
    @affiliate.users << @affiliate_user
  end

  context "when affiliate owner" do
    before do
      UserSession.create(@owner)
    end
    it "should show the make owner action" do
      render :path_parameters => {:affiliate_id => @affiliate.to_param}

      response.should have_tag(make_owner_link)
    end
  end

  context "when non-owner affiliate user" do
    before do
      UserSession.create(@affiliate_user)
    end
    it "should not show the make owner action" do
      render :path_parameters => {:affiliate_id => @affiliate.to_param}

      response.should_not have_tag(make_owner_link)
    end
  end

  def make_owner_link
    path_without_args = make_owner_affiliate_user_path(@affiliate, @affiliate_user).split("?").first
    "a[href*='#{path_without_args}']"
  end
end

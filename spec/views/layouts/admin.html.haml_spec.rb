require 'spec_helper'
describe "layouts/admin.html.haml" do
  before do
    @webtrends_tag = 'var _tag=new WebTrends();'
    activate_authlogic
    view.stub!(:current_user).and_return nil
  end

  context "when page is displayed" do
    it "should should not show webtrends javascript" do
      render
      rendered.should_not contain(@webtrends_tag)
    end
  end

end
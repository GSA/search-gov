require 'spec/spec_helper'

describe "layouts/widgets.html.haml" do
  context "when page is displayed" do
    it "should have ROBOTS meta tag" do
      render
      rendered.should have_selector("meta[name='ROBOTS'][content='NOINDEX, NOFOLLOW']")
    end
  end
end

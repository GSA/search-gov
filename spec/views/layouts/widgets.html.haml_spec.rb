require 'spec/spec_helper'

describe "layouts/widgets.html.haml" do
  context "when page is displayed" do
    before do
      render
    end
    specify { rendered.should have_selector("meta[name='ROBOTS'][content='NOINDEX, NOFOLLOW']") }
  end
end

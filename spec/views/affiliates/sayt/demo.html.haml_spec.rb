require 'spec_helper'

describe "affiliates/sayt/demo.html.haml" do
  fixtures :affiliates
  before do
    assigns[:affiliate] = @affiliate = affiliates(:basic_affiliate)
  end

  it "displays the search form" do
    render
    rendered.should have_selector("form[method='get'][action='#{search_url}']") do |form|
      form.should have_selector("input[name='affiliate'][type='hidden'][value='#{@affiliate.name}']")
      form.should have_selector("input[name='query']")
    end
  end
end

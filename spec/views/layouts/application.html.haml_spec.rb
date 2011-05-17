require 'spec/spec_helper'
describe "layouts/application.html.haml" do
  before do
    assign(:active_top_searches, [])
    controller.stub!(:controller_name).and_return "home"
    controller.stub!(:action_name).and_return "index"
    assign(:rails_sever_location_in_html_comment_for_opsview, "")
  end

  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_english.js'][type='text/javascript']")
    end

    it "should define the SAYT url" do
      render
      rendered.should contain(/var usagov_sayt_url =/)
    end
  end

  context "when locale is set to English" do
    before do
      I18n.stub!(:locale).and_return :en
    end

    it "should show the English version of the webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_english.js'][type='text/javascript']")
    end
  end

  context "when locale is set to Spanish" do
    before do
      I18n.stub!(:locale).and_return :es
    end

    it "should show the Spanish version of the webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_spanish.js'][type='text/javascript']")
    end
  end
end

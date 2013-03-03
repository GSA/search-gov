require 'spec_helper'
describe "layouts/application.html.haml" do
  fixtures :affiliates

  before do
    assign(:affiliate, affiliates(:basic_affiliate))
    controller.stub!(:controller_name).and_return "home"
    controller.stub!(:action_name).and_return "index"
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

    it "should render the English version of the favicon" do
      render
      rendered.should have_selector("link[href^='/favicon_en.ico?'][rel='shortcut icon'][type='image/vnd.microsoft.icon']")
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

    it "should render the Spanish version of the favicon" do
      render
      rendered.should have_selector("link[href^='/favicon_es.ico?'][rel='shortcut icon'][type='image/vnd.microsoft.icon']")
    end

    it "should show the Spanish version of the webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_spanish.js'][type='text/javascript']")
    end
  end
end

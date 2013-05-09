require 'spec_helper'
describe "layouts/application.mobile.haml" do
  fixtures :affiliates

  before do
    assign(:affiliate, affiliates(:basic_affiliate))
    view.stub!(:is_device?).and_return false
  end

  context "when a mobile page is displayed" do
    it "should show the page title plus the mobile site title" do
      assign(:title, "A Mobile Page")
      render
      rendered.should have_selector("title", :content => "A Mobile Page | USA.gov mobile")
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
  end

  context "when locale is set to Spanish" do
    before do
      I18n.stub!(:locale).and_return :es
    end

    it "should render the Spanish version of the favicon" do
      render
      rendered.should have_selector("link[href^='/favicon_es.ico?'][rel='shortcut icon'][type='image/vnd.microsoft.icon']")
    end
  end
end
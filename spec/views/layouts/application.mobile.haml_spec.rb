require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/application.mobile.haml" do
  before do
    view.stub!(:is_device?).and_return false
  end

  context "when a mobile page is displayed" do
    it "should show the mobile webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_mobile_english.js'][type='text/javascript']")
    end
  end

  context "when locale is set to English" do
    before do
      I18n.stub!(:locale).and_return :en
    end
    
    it "should show the English version of the mobile webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_mobile_english.js'][type='text/javascript']")
    end
  end

  context "when locale is set to Spanish" do
    before do
      I18n.stub!(:locale).and_return :es
    end

    it "should show the Spanish version of the mobile webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_mobile_spanish.js'][type='text/javascript']")
    end
  end
end
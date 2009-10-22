require "#{File.dirname(__FILE__)}/../spec_helper"

describe ApplicationHelper do
  describe "#other_locale_str" do
    it "should toggle between English and Spanish locales (both strings and symbols)" do
      I18n.locale = :es
      helper.other_locale_str.should == "en"
      I18n.locale = :en
      helper.other_locale_str.should == "es"
      I18n.locale = "es"
      helper.other_locale_str.should == "en"
      I18n.locale = "en"
      helper.other_locale_str.should == "es"
    end
  end
end
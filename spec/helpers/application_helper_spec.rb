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

  describe "#locale_dependent_background_color" do
    it "should default to bgcolor for English locale" do
      helper.locale_dependent_background_color.should == ApplicationHelper::BACKGROUND_COLORS[:en]
      I18n.locale = :xx
      helper.locale_dependent_background_color.should == ApplicationHelper::BACKGROUND_COLORS[:en]      
    end

    it "should return bgcolor for locale" do
      I18n.locale = :es
      helper.locale_dependent_background_color.should == ApplicationHelper::BACKGROUND_COLORS[:es]
    end
  end
end
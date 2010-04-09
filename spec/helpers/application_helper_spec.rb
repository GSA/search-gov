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
  
  describe "#build_page_title" do
    context "for the English site" do
      before do
        I18n.locale = :en
      end
      
      context "when a page title is not defined" do
        it "should return the English site title" do
          helper.build_page_title(nil) == (t :site_title)
        end
      end
      
      context "when a page title is blank" do
        it "should return the English site title" do
          helper.build_page_title("").should == (t :site_title)
        end
      end
      
      context "when a non-blank page title is defined" do
        it "should prefix the defined page title with the English site title" do
          helper.build_page_title("some title").should == "some title - #{t :site_title}"
        end
      end
    end
    context "for the Spanish site" do
      before do
        I18n.locale = :es
      end
      
      context "when a page title is not defined" do
        it "should return the Spanish site title" do
          helper.build_page_title(nil) == (t :site_title)
        end
      end
      
      context "when a page title is blank" do
        it "should return the Spanish site title" do
          helper.build_page_title("").should == (t :site_title)
        end
      end
      
      context "when a non-blank page title is defined" do
        it "should prefix the defined page title with the Spanish site title" do
          helper.build_page_title("some title").should == "some title - #{t :site_title}"
        end
      end
      
      after do
        I18n.locale = I18n.default_locale
      end
    end
  end
end
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

  describe "#display for specific role" do
    context "when the current user is an affiliate_admin" do
      it "display the content" do
        user = stub('User', :is_affiliate_admin? => true)
        helper.stub(:current_user).and_return(user)
        content = helper.display_for(:affiliate_admin) {"content"}
        content.should == "content"
      end
    end

    context "when the current user is an analyst_admin" do
      it "display the content" do
        user = stub('User', :is_analyst_admin? => true)
        helper.stub(:current_user).and_return(user)
        content = helper.display_for(:analyst_admin) {"content"}
        content.should == "content"
      end
    end

    context "when the current user is an affiliate" do
      it "display the content" do
        user = stub('User', :is_affiliate? => true)
        helper.stub(:current_user).and_return(user)
        content = helper.display_for(:affiliate) {"content"}
        content.should == "content"
      end
    end

    context "when the current user has no role" do
      it "does not display the content" do
        user = stub('User', :is_affiliate_admin? => false, :is_analyst_admin? => false, :is_affiliate? => false)
        helper.stub(:current_user).and_return(user)
        content = helper.display_for(:affiliate_admin) {"content"}
        content.should == nil
        content = helper.display_for(:analyst_admin) {"content"}
        content.should == nil
        content = helper.display_for(:affiliate) {"content"}
        content.should == nil
      end
    end
  end
end
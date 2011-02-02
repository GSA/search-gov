require "#{File.dirname(__FILE__)}/../spec_helper"

describe ApplicationHelper do
  before do
    helper.stub!(:forms_search?).and_return false
  end
  
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

  describe "time_ago_in_words" do
    it "should include 'ago'" do
      time_ago_in_words(4.hours.ago).should == "about 4 hours ago"
      time_ago_in_words(1.month.ago).should == "about 1 month ago"
      time_ago_in_words(2.days.ago).should == "2 days ago"
      time_ago_in_words(1.day.ago).should == "1 day ago"
    end

    context "es" do
      before :each do
        I18n.locale = :es
      end
      after :each do
        I18n.locale = :en
      end
      it "should use the Aproximadamente form" do
        time_ago_in_words(4.hours.ago).should == "Aproximadamente desde hace 4 horas"
        time_ago_in_words(1.month.ago).should == "Aproximadamente desde hace un mes"
        time_ago_in_words(2.days.ago).should == "Desde hace 2 días"
        time_ago_in_words(1.day.ago).should == "Desde ayer"
      end
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
      
      context "when it's a forms page" do
        before do
          helper.stub!(:forms_search?).and_return true
        end
        
        context "when the page title is not defined" do
          it "should return the forms title" do
            helper.build_page_title(nil).should == (t :forms_site_title)
          end
        end
        
        context "when a non-blank page title is defined" do
          it "should prefix the defined page title with the English forms site title" do
            helper.build_page_title("some title").should == "some title - #{t :forms_site_title}"
          end
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

  describe "#basic_header_navigation_for" do
    before(:each) do
      helper.stub(:ssl_protocol).and_return("aprotocol")
    end

    context "when user is not logged in" do
      it "should use generate Sign In link with predefined SSL_PROTOCOL" do
        content = helper.basic_header_navigation_for(nil)
        content.should have_tag("a[href^=aprotocol]", "Sign In")
      end

      it "should contain Sign In and Help Desk links" do
        content = helper.basic_header_navigation_for(nil)
        content.should have_tag("a", "Sign In")
        content.should have_tag("a", "Help Desk")
        content.should_not have_tag("a", "My Account")
        content.should_not have_tag("a", "Sign Out")
      end
    end

    context "when user is logged in" do
      it "should use generate Sign Out link with predefined SSL_PROTOCOL" do
        user = stub("User", :email => "user@fixtures.org")
        content = helper.basic_header_navigation_for(user)
        content.should have_tag("a[href^=aprotocol]", "Sign Out")
      end
    end

    it "should contain My Account and Sign Out links" do
      user = stub("User", :email => "user@fixtures.org")
      content = helper.basic_header_navigation_for(user)
      content.should_not have_tag("a", "Sign In")
      content.should have_tag("a", "Help Desk")
      content.should have_tag("a", "My Account")
      content.should have_tag("a", "Sign Out")
    end
  end

  describe "#analytics_header_navigation_for" do
    context "when user is not logged in" do
      it "should contain Help Desk link" do
        content = helper.analytics_header_navigation_for(nil)
        content.should_not have_tag("a", "My Account")
        content.should_not have_tag("a", "Query Groups Admin")
        content.should_not have_tag("a", "Sign Out")
        content.should have_tag("a", "Help Desk")
      end
    end

    context "when analyst admin is logged in" do
      it "should contain My Account, Query Groups Admin, Sign Out and Help Desk" do
        user = stub("User", :email => "user@fixtures.org", :is_analyst_admin? => true)
        content = helper.analytics_header_navigation_for(user)
        content.should have_tag("a", "My Account")
        content.should have_tag("a", "Query Groups Admin")
        content.should have_tag("a", "Sign Out")
        content.should have_tag("a", "Help Desk")
      end
    end

    context "when non analyst admin is logged in" do
      it "should contain My Account, Sign Out and Help Desk" do
        user = stub("User", :email => "user@fixtures.org", :is_analyst_admin? => false)
        content = helper.analytics_header_navigation_for(user)
        content.should have_tag("a", "My Account")
        content.should_not have_tag("a", "Query Groups Admin")
        content.should have_tag("a", "Sign Out")
        content.should have_tag("a", "Help Desk")
      end
    end
  end

  describe "#truncate_on_words" do
    it "should replace excess words with ..." do
      helper.truncate_on_words("asdfasdf jkl;", 8).should == "asdfasdf..."
    end

    it "should not append ... if the text length < max length" do
      helper.truncate_on_words("asdf jkl;", 10).should == "asdf jkl;"
    end

    it "should split on word boundaries" do
      helper.truncate_on_words("asdf jkl;", 7).should == "asdf..."
    end

    it "should return the right number of characters if it is a single word" do
      helper.truncate_on_words("asdfjkl;", 7).should == "asdfjkl..."
    end

    it "should not end in ,..." do
      helper.truncate_on_words("asdfjkl, askjdn", 7).should == "asdfjkl..."
      helper.truncate_on_words("asdfjkl, askjdn", 8).should == "asdfjkl..."
      helper.truncate_on_words("asdfjkl, askjdn", 9).should == "asdfjkl..."
    end
  end
end

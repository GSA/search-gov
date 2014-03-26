# coding: utf-8
require 'spec_helper'

describe ApplicationHelper do
  before do
    helper.stub!(:image_search?).and_return false
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
      time_ago_in_words(33.days.ago).should == "about 1 month ago"
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
        time_ago_in_words(4.hours.ago).should == "Hace 4 horas"
        time_ago_in_words(33.days.ago).should == "Hace un mes"
        time_ago_in_words(2.days.ago).should == "Hace 2 días"
        time_ago_in_words(1.day.ago).should == "Ayer"
      end
    end
  end

  describe "localize dates" do
    context "es" do
      before :each do
        I18n.locale = :es
      end
      after :each do
        I18n.locale = :en
      end

      describe "medium localization" do
        it "should look like 29 de enero de 2011" do
          l(Date.parse('2011-01-29'), :format => :medium).should == "29 de enero de 2011"
        end

        (1..12).each do |month|
          it "should work for month #{month}" do
            date = Date.parse("2011-%02i-22" % month)
            l(date, :format => :medium)
          end
        end
      end
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
          helper.build_page_title("some title").should == "some title - #{t :serp_title}"
        end
      end

      context "when it's the images page" do
        before do
          helper.stub!(:image_search?).and_return true
        end

        context "when the page title is not defined" do
          it "should return the image title" do
            helper.build_page_title(nil).should == (t :images_site_title)
          end
        end

        context "when a non-blank page title is defined" do
          it "should prefix the defined page title with the English image site title" do
            helper.build_page_title("some title").should == "some title - #{t :images_site_title}"
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
        it "should prefix the defined page title with the Spanish serp title" do
          helper.build_page_title("some title").should == "some title - #{t :serp_title}"
        end
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end
  end

  describe "#current_user_is? for specific role" do
    context "when the current user is an affiliate_admin" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate_admin).should be_true
      end
    end

    context "when the current user is an affiliate" do
      it "should detect that" do
        user = stub('User', :is_affiliate? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be_true
      end
    end

    context "when the current user has no role" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => false, :is_affiliate? => false)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be_false
        helper.current_user_is?(:affiliate_admin).should be_false
      end
    end

    context "when there is no current user" do
      it "should detect that" do
        helper.stub(:current_user).and_return(nil)
        helper.current_user_is?(:affiliate).should be_false
        helper.current_user_is?(:affiliate_admin).should be_false
      end
    end

  end

  describe "#basic_header_navigation_for" do
    it "should contain My Account and Sign Out links" do
      user = stub("User", :email => "user@fixtures.org")
      content = helper.basic_header_navigation_for(user)
      content.should_not have_selector("a", :content => "Sign In")
      content.should contain("user@fixtures.org")
      content.should have_selector("a", :content => "My Account")
      content.should have_selector("a", :content => "Sign Out")
    end
  end

end

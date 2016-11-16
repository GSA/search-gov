# coding: utf-8
require 'spec_helper'

describe ApplicationHelper do
  before do
    helper.stub(:image_search?).and_return false
  end

  describe "time_ago_in_words" do
    context 'English' do
      it "should include 'ago'" do
        time_ago_in_words(4.hours.ago).should == "about 4 hours ago"
        time_ago_in_words(33.days.ago).should == "about 1 month ago"
        time_ago_in_words(2.days.ago).should == "2 days ago"
        time_ago_in_words(1.day.ago).should == "1 day ago"
      end
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

  describe "#current_user_is? for specific role" do
    context "when the current user is an affiliate_admin" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate_admin).should be true
      end
    end

    context "when the current user is an affiliate" do
      it "should detect that" do
        user = stub('User', :is_affiliate? => true)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be true
      end
    end

    context "when the current user has no role" do
      it "should detect that" do
        user = stub('User', :is_affiliate_admin? => false, :is_affiliate? => false)
        helper.stub(:current_user).and_return(user)
        helper.current_user_is?(:affiliate).should be false
        helper.current_user_is?(:affiliate_admin).should be false
      end
    end

    context "when there is no current user" do
      it "should detect that" do
        helper.stub(:current_user).and_return(nil)
        helper.current_user_is?(:affiliate).should be_falsey
        helper.current_user_is?(:affiliate_admin).should be_falsey
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

require 'spec_helper'

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :report_recipients, :users, :features

  describe "#objectionable_content_alert" do
    before(:all) do
      @email = Emailer.objectionable_content_alert("foo@bar.com", %w{ baaaaad awful }).deliver
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("foo@bar.com")
    end

    it "should have the correct subject" do
      @email.should have_subject(/Objectionable Content Alert/)
    end

    it "should contain search links for each term" do
      @email.should have_body_text(/baaaaad/)
      @email.should have_body_text(/awful/)
    end
  end

  describe "#saucelabs_report" do
    before(:all) do
      @url = "http://cdn.url"
      @email = Emailer.saucelabs_report("foo@bar.com", @url).deliver
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("foo@bar.com")
    end

    it "should have the correct subject" do
      @email.should have_subject(/Sauce Labs Report/)
    end

    it "should contain URL to report" do
      @email.should have_body_text(/#{@url}/)
    end
  end

  describe "#feature_admonishment(user, affiliates_with_unused_features)" do
    let(:user) { users(:another_affiliate_manager) }
    before do
      AffiliateFeatureAddition.delete_all
      user.affiliates.first.features << Feature.first
      @email = Emailer.feature_admonishment(user, user.affiliates).deliver
    end

    it "should be sent to the user's email" do
      @email.should deliver_to(user.email)
    end

    it "should have 'Getting started with USASearch features' as the subject" do
      @email.should have_subject(/Getting started with USASearch features/)
    end

    it "should contain lists of unadopted features for each affiliate that has any" do
      @email.should have_body_text(/I noticed you registered for a new USASearch account a few days ago so I wanted to follow up to see if you have any questions/)
      @email.should have_body_text(/laksjdflkjasldkjfalskdjf.gov:\n\nDiscovery Tag\n\nSAYT/)
    end
  end

  describe "#new_feature_adoption_to_admin" do
    before do
      AffiliateFeatureAddition.delete_all
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:disco))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:disco), :created_at => 2.days.ago)
      @email = Emailer.new_feature_adoption_to_admin.deliver
    end

    it "should be sent to the admin email" do
      @email.should deliver_to('usagov@searchsi.com')
    end

    it "should have 'Features adopted by customers yesterday' in the subject" do
      @email.should have_subject(/Features adopted by customers yesterday/)
    end

    it "should contain lists of newly adopted features for each affiliate that has any" do
      @email.should have_body_text("Yesterday, these customers turned on some features:")
      @email.should have_body_text("NPS Site (nps.gov):\nDiscovery Tag\nSAYT")
      @email.should have_body_text("Noaa Site (noaa.gov):\nSAYT")
    end
  end

  describe "#new_user_email_verification" do
    before do
      @user = mock(User, :email => 'admin@agency.gov', :contact_name => 'Admin', :email_verification_token => 'some_special_token')
      @email = Emailer.new_user_email_verification(@user).deliver
    end

    it "should be sent to the new user email" do
      @email.should deliver_to('admin@agency.gov')
    end

    it "should have 'Email Verification' as the subject" do
      @email.should have_subject(/Email Verification/)
    end

    it "should have 'Verify Now' link" do
      @email.should have_body_text(/http:\/\/localhost:3000\/email_verification\/some_special_token/)
    end
  end

  describe "#new_user_to_admin" do
    context "affiliate user has .com email address" do
      before do
        @user = mock(User,
                     :email => 'not.gov.user@agency.com',
                     :contact_name => 'Contractor Joe',
                     :affiliates => [],
                     :organization_name => 'Agency',
                     :requires_manual_approval? => true)
        @email = Emailer.new_user_to_admin @user
      end

      it "should be sent to the admin email" do
        @email.should deliver_to('usagov@searchsi.com')
      end

      it "should have 'New user signed up for USA Search Services' as the subject" do
        @email.should have_subject(/New user signed up for USA Search Services/)
      end

      it "should have 'This user signed up as an affiliate, but the user doesn't have a .gov or .mil email address. Please verify and approve this user.' text" do
        @email.should have_body_text(/This user signed up as an affiliate, but the user doesn't have a \.gov or \.mil email address\. Please verify and approve this user\./)
      end
    end

    context "affiliate user has .gov email address" do
      before do
        @user = mock(User,
                     :email => 'not.com.user@agency.gov',
                     :contact_name => 'Gov Employee Joe',
                     :affiliates => [],
                     :organization_name => 'Gov Agency',
                     :requires_manual_approval? => false)
        @email = Emailer.new_user_to_admin @user
      end

      it "should be sent to the admin email" do
        @email.should deliver_to('usagov@searchsi.com')
      end

      it "should have 'New user signed up for USA Search Services' as the subject" do
        @email.should have_subject(/New user signed up for USA Search Services/)
      end

      it "should not have 'This user signed up as an affiliate, but the user doesn't have a .gov or .mil email address. Please verify and approve this user.' text" do
        @email.should_not have_body_text /This user signed up as an affiliate/
      end
    end

    context "user got invited by another customer" do
      before do
        @user = users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status)
        @user.affiliates << affiliates(:gobiernousa_affiliate)
        @user.affiliates << affiliates(:power_affiliate)
        @user.save!
        @user.reload
        @user.inviter = users(:affiliate_manager)
        @email = Emailer.new_user_to_admin @user
      end

      it "should have info about who invited whom to which affiliate" do
        @email.should have_body_text /This user was added to affiliate 'Noaa Site' by Affiliate Manager\. This user will be automatically approved after they verify their email\./
      end
    end

    context "user didn't get invited by another customer (and thus has no affiliates either)" do
      before do
        @user = mock(User,
                     :email => 'not.com.user@agency.gov',
                     :contact_name => 'Gov Employee Joe',
                     :organization_name => 'Gov Agency',
                     :affiliates => [],
                     :requires_manual_approval? => false)
        @email = Emailer.new_user_to_admin @user
      end

      it "should not have invitation info" do
        @email.should_not have_body_text /This user was added to affiliate/
      end
    end
  end

  describe "#welcome_to_new_user_added_by_affiliate" do
    before do
      @user = mock(User, :email => "invitee@agency.com", :contact_name => 'Invitee Joe', :email_verification_token => 'some_special_token')
      @current_user = mock(User, :email => "inviter@agency.com", :contact_name => 'Inviter Jane')
      @affiliate = affiliates(:basic_affiliate)
      @email = Emailer.welcome_to_new_user_added_by_affiliate(@affiliate, @user, @current_user)
    end

    it "should be sent to the invitee" do
      @email.should deliver_to("invitee@agency.com")
    end

    it "should have Welcome to the USASearch Affiliate Program as the subject" do
      @email.should have_subject(/Welcome to the USASearch Affiliate Program/)
    end

    it "should have complete registration link" do
      @email.should have_body_text(/http:\/\/localhost:3000\/complete_registration\/some_special_token\/edit/)
    end
  end

  context "#affiliate_monthly_report" do
    fixtures :users, :affiliates
    before do
      @user = users(:affiliate_manager)
      @affiliate = affiliates(:basic_affiliate)
      report_date = Date.parse('2012-04-13')
      DailyUsageStat.destroy_all
      DailySearchModuleStat.destroy_all
      DailyUsageStat.create(:day => report_date, :affiliate => @affiliate.name, :total_queries => 100)
      DailyUsageStat.create(:day => report_date - 1.month, :affiliate => @affiliate.name, :total_queries => 75)
      DailyUsageStat.create(:day => report_date - 1.year, :affiliate => @affiliate.name, :total_queries => 150)
      DailySearchModuleStat.create!(:day => report_date, :affiliate_name => @affiliate.name, :clicks => 100, :locale => 'en', :vertical => 'test', :module_tag => 'test', :impressions => 1000)
      DailyQueryStat.destroy_all
      ['query1', 'query2', 'query3'].each_with_index do |query, index|
        DailyQueryStat.create!(:day => report_date, :query => query, :affiliate => @affiliate.name, :times => 100)
      end
      @email = Emailer.affiliate_monthly_report(@user, report_date)
    end

    it "should be sent to the email address of the user specified" do
      @email.should deliver_to(@user.email)
    end

    it "should have a subject which includes the month/year specified" do
      @email.should have_subject(/April 2012/)
    end

    it "should calculate the proper totals for the data in the database" do
      body = Sanitize.clean(@email.default_part_body.to_s).squish
      body.should include('100 33.33% -33.33% 100')
      body.should include('0 0.00% 0.00% 0')
      body.should include('Most Popular Queries for April 2012')
      body.should include('NPEspanol Site Not enough historic data to compute most popular')
      body.should include('query1 100')
      body.should include('query2 100')
      body.should include('query3 100')
    end
  end

  context "when a template is missing" do
    before do
      @user = mock(User, :email => "invitee@agency.com", :contact_name => 'Invitee Joe', :email_verification_token => 'some_special_token')
      @current_user = mock(User, :email => "inviter@agency.com", :contact_name => 'Inviter Jane')
      @affiliate = affiliates(:basic_affiliate)
      EmailTemplate.destroy_all
      @email = Emailer.welcome_to_new_user_added_by_affiliate(@affiliate, @user, @current_user)
    end

    it "should send an email to the developers" do
      @email.should deliver_to(Emailer::DEVELOPERS_EMAIL)
    end

    it "should tell the developers to create a template for that method" do
      @email.should have_body_text(/Someone tried to send an email via the welcome_to_new_user_added_by_affiliate method, but we don\'t have a template for that method.  Please create one.  Thanks!/)
    end

    after do
      EmailTemplate.load_default_templates
    end
  end
end

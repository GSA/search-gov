require 'spec_helper'

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :report_recipients, :users, :features

  describe "#objectionable_content_alert" do
    subject { Emailer.objectionable_content_alert('foo@bar.com', %w{ baaaaad awful }).deliver }

    it { should deliver_to('foo@bar.com') }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Objectionable Content Alert/) }
    it { should have_body_text(/baaaaad/) }
    it { should have_body_text(/awful/) }
  end

  describe "#saucelabs_report" do
    let(:url) { 'http://cdn.url' }

    subject { Emailer.saucelabs_report('foo@bar.com', url).deliver }

    it { should deliver_to('foo@bar.com') }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Sauce Labs Report/) }
    it { should have_body_text(/#{url}/) }
  end

  describe "#feature_admonishment(user, affiliates_with_unused_features)" do
    let(:user) { users(:another_affiliate_manager) }

    before do
      AffiliateFeatureAddition.delete_all
      user.affiliates.first.features << Feature.first
    end

    subject(:email) { Emailer.feature_admonishment(user, user.affiliates).deliver }

    it { should deliver_to(user.email) }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Getting started with USASearch features/) }

    it 'should contain lists of unadopted features for each affiliate that has any' do
      email.should have_body_text(/I noticed you registered for a new USASearch account a few days ago so I wanted to follow up to see if you have any questions/)
      email.should have_body_text(/laksjdflkjasldkjfalskdjf.gov:\n\nDiscovery Tag\n\nSAYT/)
    end
  end

  describe "#new_feature_adoption_to_admin" do
    before do
      AffiliateFeatureAddition.delete_all
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:disco))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:disco), :created_at => 2.days.ago)
    end

    subject(:email) { Emailer.new_feature_adoption_to_admin.deliver }

    it { should deliver_to('usagov@searchsi.com') }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Features adopted by customers yesterday/) }

    it 'should contain lists of newly adopted features for each affiliate that has any' do
      email.should have_body_text("Yesterday, these customers turned on some features:")
      email.should have_body_text("NPS Site (nps.gov):\nDiscovery Tag\nSAYT")
      email.should have_body_text("Noaa Site (noaa.gov):\nSAYT")
    end
  end

  describe "#new_user_email_verification" do
    let(:user) { mock(User, :email => 'admin@agency.gov', :contact_name => 'Admin', :email_verification_token => 'some_special_token') }

    subject { Emailer.new_user_email_verification(user).deliver }

    it { should deliver_to('admin@agency.gov') }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Email Verification/) }
    it { should have_body_text(/http:\/\/localhost:3000\/email_verification\/some_special_token/) }
  end

  describe "#new_user_to_admin" do
    context "affiliate user has .com email address" do
      let(:user) do
        mock(User,
             :email => 'not.gov.user@agency.com',
             :contact_name => 'Contractor Joe',
             :affiliates => [],
             :organization_name => 'Agency',
             :requires_manual_approval? => true)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@searchsi.com') }
      it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
      it { should have_subject(/New user signed up for USA Search Services/) }
      it { should have_body_text(/This user signed up as an affiliate, but the user doesn't have a \.gov or \.mil email address\. Please verify and approve this user\./) }
    end

    context "affiliate user has .gov email address" do
      let(:user) do
        mock(User,
             :email => 'not.com.user@agency.gov',
             :contact_name => 'Gov Employee Joe',
             :affiliates => [],
             :organization_name => 'Gov Agency',
             :requires_manual_approval? => false)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@searchsi.com') }
      it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
      it { should have_subject(/New user signed up for USA Search Services/) }
      it { should_not have_body_text /This user signed up as an affiliate/ }
    end

    context "user got invited by another customer" do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }

      before do
        user.affiliates << affiliates(:gobiernousa_affiliate)
        user.affiliates << affiliates(:power_affiliate)
        user.save!
        user.reload
        user.inviter = users(:affiliate_manager)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@searchsi.com') }
      it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
      it { should have_body_text /This user was added to affiliate 'Noaa Site' by Affiliate Manager\. This user will be automatically approved after they verify their email\./ }
    end

    context "user didn't get invited by another customer (and thus has no affiliates either)" do
      let(:user) do
        mock(User,
             :email => 'not.com.user@agency.gov',
             :contact_name => 'Gov Employee Joe',
             :organization_name => 'Gov Agency',
             :affiliates => [],
             :requires_manual_approval? => false)

      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@searchsi.com') }
      it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
      it { should_not have_body_text /This user was added to affiliate/ }
    end
  end

  describe "#welcome_to_new_user_added_by_affiliate" do
    let(:user) do
      mock(User,
           :email => "invitee@agency.com",
           :contact_name => 'Invitee Joe',
           :email_verification_token => 'some_special_token')
    end

    let(:current_user) { mock_model(User, :email => "inviter@agency.com", :contact_name => 'Inviter Jane') }
    let(:affiliate) { affiliates(:basic_affiliate) }

    subject { Emailer.welcome_to_new_user_added_by_affiliate(affiliate, user, current_user) }

    it { should deliver_to("invitee@agency.com") }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/Welcome to the USASearch Affiliate Program/) }
    it { should have_body_text(/http:\/\/localhost:3000\/complete_registration\/some_special_token\/edit/) }
  end

  context "#affiliate_monthly_report" do
    let(:user) { users(:affiliate_manager) }
    let(:report_date) { Date.parse('2012-04-13') }

    before do
      affiliate = affiliates(:basic_affiliate)
      DailyUsageStat.destroy_all
      DailySearchModuleStat.destroy_all
      DailyUsageStat.create(:day => report_date, :affiliate => affiliate.name, :total_queries => 100)
      DailyUsageStat.create(:day => report_date - 1.month, :affiliate => affiliate.name, :total_queries => 75)
      DailyUsageStat.create(:day => report_date - 1.year, :affiliate => affiliate.name, :total_queries => 150)
      DailySearchModuleStat.create!(:day => report_date, :affiliate_name => affiliate.name, :clicks => 100, :locale => 'en', :vertical => 'test', :module_tag => 'test', :impressions => 1000)
      DailyQueryStat.destroy_all
      ['query1', 'query2', 'query3'].each_with_index do |query, index|
        DailyQueryStat.create!(:day => report_date, :query => query, :affiliate => affiliate.name, :times => 100)
      end
    end

    subject(:email) { Emailer.affiliate_monthly_report(user, report_date) }

    it { should deliver_to(user.email) }
    it { should bcc_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject(/April 2012/) }

    it "should calculate the proper totals for the data in the database" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
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
    let(:user) { mock(User, :email => "invitee@agency.com", :contact_name => 'Invitee Joe', :email_verification_token => 'some_special_token') }
    let(:current_user) { mock(User, :email => "inviter@agency.com", :contact_name => 'Inviter Jane') }
    let(:affiliate) { affiliates(:basic_affiliate) }

    before { EmailTemplate.destroy_all }

    subject { Emailer.welcome_to_new_user_added_by_affiliate(affiliate, user, current_user) }

    it { should deliver_to(Emailer::DEVELOPERS_EMAIL) }
    it { should have_subject('[USASearch] Missing Email template') }
    it { should have_body_text(/Someone tried to send an email via the welcome_to_new_user_added_by_affiliate method, but we don\'t have a template for that method.  Please create one.  Thanks!/) }

    after { EmailTemplate.load_default_templates }
  end
end
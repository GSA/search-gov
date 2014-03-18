require 'spec_helper'

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :users, :features, :memberships

  describe "#feature_admonishment(user, affiliates_with_unused_features)" do
    let(:user) { users(:another_affiliate_manager) }

    before do
      AffiliateFeatureAddition.delete_all
      user.affiliates.first.features << Feature.first
    end

    subject(:email) { Emailer.feature_admonishment(user, user.affiliates).deliver }

    it { should deliver_to(user.email) }
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should deliver_from(Emailer::DELIVER_FROM_EMAIL_ADDRESS) }
    it { should have_subject(/Getting started with USASearch/) }

    it 'should contain lists of unadopted features for each affiliate that has any' do
      email.should have_body_text(/Now that you've had a few days to dig into USASearch/)
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

    it { should deliver_to('usagov@mail.usasearch.howto.gov') }
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject(/Features adopted yesterday/) }

    it 'should contain lists of newly adopted features for each affiliate that has any' do
      email.should have_body_text("Yesterday, these customers turned on some features:")
      email.should have_body_text("NPS Site (nps.gov):\nDiscovery Tag\nSAYT")
      email.should have_body_text("Noaa Site (noaa.gov):\nSAYT")
    end
  end

  describe "#deep_collection_notification" do
    let(:document_collection) do
      affiliates(:basic_affiliate).document_collections.create!(
        :name => 'WH only',
        :url_prefixes_attributes => {'0' => {:prefix => 'http://www.whitehouse.gov/photos-and-video/'},
                                     '1' => {:prefix => 'http://www.whitehouse.gov/blog/is/deep'}})
    end

    subject(:email) { Emailer.deep_collection_notification(users(:affiliate_manager), document_collection).deliver }

    it { should deliver_to('usagov@mail.usasearch.howto.gov') }
    it { should have_subject(/Deep collection created/) }

    it 'should contain document collection and URL prefixes' do
      email.should have_body_text("WH only")
      email.should have_body_text('http://www.whitehouse.gov/photos-and-video/')
      email.should have_body_text('http://www.whitehouse.gov/blog/is/deep')
    end
  end

  describe "#filtered_popular_terms_report" do
    subject(:email) { Emailer.filtered_popular_terms_report(%w{foo bar blat}).deliver }

    it { should deliver_to('usagov@mail.usasearch.howto.gov') }
    it { should have_subject(/Filtered Popular Terms for Last Week/) }

    it 'should contain list of filtered sayt suggestions' do
      email.should have_body_text("foo")
      email.should have_body_text("bar")
      email.should have_body_text("blat")
    end
  end

  describe "#new_user_email_verification" do
    let(:user) { mock(User, :email => 'admin@agency.gov', :contact_name => 'Admin', :email_verification_token => 'some_special_token') }

    subject { Emailer.new_user_email_verification(user).deliver }

    it { should deliver_to('admin@agency.gov') }
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject(/Verify your email/) }
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

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
      it { should have_subject(/New user sign up/) }
      it { should have_body_text(/Name: Contractor Joe\nEmail: not.gov.user@agency.com\nOrganization name: Agency\n\n\n    This person doesn't have a .gov or .mil email address/) }
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

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
      it { should have_subject(/New user sign up/) }
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

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
      it { should have_body_text /Name: Invited Affiliate Manager\nEmail: affiliate_added_by_another_affiliate@fixtures.org\nOrganization name: Agency\n\n\n    Affiliate Manager added this person to 'Noaa Site'. He'll be approved after verifying his email./ }
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

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
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
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject(/Welcome to USASearch/) }
    it { should have_body_text(/http:\/\/localhost:3000\/complete_registration\/some_special_token\/edit/) }
  end

  describe '#daily_snapshot' do
    let(:membership) { memberships(:four) }

    before do
      DailyQueryStat.destroy_all
      DailyQueryNoresultsStat.destroy_all
      DailyClickStat.destroy_all
      QueriesClicksStat.destroy_all
      ['query1', 'query2', 'query3'].each_with_index do |query, index|
        DailyQueryStat.create!(day: Date.yesterday, query: query, affiliate: membership.affiliate.name, times: 100 + index)
        DailyQueryNoresultsStat.create!(day: Date.yesterday, query: "#{query}blah", affiliate: membership.affiliate.name, times: 1 + index)
        DailyClickStat.create!(day: Date.yesterday, url: "http://www.nps.gov/#{query}", affiliate: membership.affiliate.name, times: 6 + index)
        QueriesClicksStat.create!(day: Date.yesterday, url: "http://www.nps.gov/#{query}", query: query, affiliate: membership.affiliate.name, times: 6 + index)
      end
    end

    subject(:email) { Emailer.daily_snapshot(membership) }

    it { should deliver_to(membership.user.email) }
    it { should have_subject(/Today's Snapshot for #{membership.affiliate.name} on #{Date.yesterday}/) }

    it "should contain the daily shapshot tables for yesterday" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('Top Queries')
      body.should include('Query # of Queries')
      body.should include('1. query3 102')
      body.should include('2. query2 101')
      body.should include('3. query1 100')

      body.should include('Top Clicked URLs')
      body.should include('URL # of Clicks')
      body.should include('1. http://www.nps.gov/query3 8')
      body.should include('2. http://www.nps.gov/query2 7')
      body.should include('3. http://www.nps.gov/query1 6')

      body.should include('Trending Queries')
      body.should include('query3')
      body.should include('query2')
      body.should include('query1')

      body.should include('Queries with No Results')
      body.should include('Query # of Queries')
      body.should include('1. query3blah 3')
      body.should include('2. query2blah 2')
      body.should include('3. query1blah 1')

      body.should include('Top Queries with Low Click Thrus')
      body.should include('Query CTR %')
      body.should include('1. query1 6%')
      body.should include('2. query2 6%')
      body.should include('3. query3 7%')
    end
  end

  describe "#affiliate_monthly_report" do
    let(:user) { users(:affiliate_manager) }
    let(:report_date) { Date.parse('2012-04-13') }

    before do
      affiliate = affiliates(:basic_affiliate)
      DailyUsageStat.destroy_all
      DailyQueryStat.destroy_all
      DailySearchModuleStat.destroy_all
      DailyUsageStat.create!(:day => report_date, :affiliate => affiliate.name, :total_queries => 100)
      DailyUsageStat.create!(:day => report_date - 1.month, :affiliate => affiliate.name, :total_queries => 75)
      DailyUsageStat.create!(:day => report_date - 1.year, :affiliate => affiliate.name, :total_queries => 150)
      DailySearchModuleStat.create!(:day => report_date, :affiliate_name => affiliate.name, :clicks => 100, :locale => 'en', :vertical => 'test', :module_tag => 'test', :impressions => 1000)
      %w(query1 query2 query3).each { |query| DailyQueryStat.create!(:day => report_date, :query => query, :affiliate => affiliate.name, :times => 100) }
    end

    subject(:email) { Emailer.affiliate_monthly_report(user, report_date) }

    it { should deliver_to(user.email) }
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject(/April 2012/) }

    it "should calculate the proper totals for the data in the database" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('100 33.33% -33.33% 100')
      body.should include('0 0.00% 0.00% 0')
      body.should include('Top 10 Searches for April 2012')
      body.should include('NPEspanol Site Not enough historic data to compute most popular')
      body.should include('query1 100')
      body.should include('query2 100')
      body.should include('query3 100')
    end
  end

  describe "#affiliate_yearly_report" do
    let(:user) { users(:affiliate_manager) }
    let(:report_year) { 2012 }

    before do
      affiliate = affiliates(:basic_affiliate)
      DailyQueryStat.destroy_all
      report_date = Date.civil(report_year, 1, 1)
      %w{query1 query2 query3}.each do |query|
        DailyQueryStat.create!(:day => report_date, :query => query, :affiliate => affiliate.name, :times => 100)
      end
    end

    subject(:email) { Emailer.affiliate_yearly_report(user, report_year) }

    it { should deliver_to(user.email) }
    it { should bcc_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject(/2012 Year in Review/) }

    it "should calculate the proper totals for the data in the database" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('Most Popular Queries for 2012')
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

    it { should deliver_to(Emailer::BCC_TO_EMAIL_ADDRESS) }
    it { should have_subject('[USASearch] Missing Email template') }
    it { should have_body_text(/Someone tried to send an email via the welcome_to_new_user_added_by_affiliate method, but we don\'t have a template for that method.  Please create one.  Thanks!/) }

    after { EmailTemplate.load_default_templates }
  end
end

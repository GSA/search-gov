require 'spec_helper'

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :users, :features, :memberships

  let(:bcc_setting) { 'bcc@example.com' }

  before do
    mandrill_adapter = double(MandrillAdapter, bcc_setting: bcc_setting)
    MandrillAdapter.stub(:new).and_return(mandrill_adapter)
  end

  describe '#user_approval_removed' do
    let(:user) { users(:another_affiliate_manager) }

    subject(:email) { Emailer.user_approval_removed(user) }

    it { should deliver_to("usagov@mail.usasearch.howto.gov") }
    it { should have_body_text "The following user is no longer associated with any sites" }
    it { should have_body_text user.contact_name }
    it { should have_body_text user.email }
    it { should have_body_text user.organization_name }
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
    it { should bcc_to(bcc_setting) }
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
        :url_prefixes_attributes => { '0' => { :prefix => 'http://www.whitehouse.gov/photos-and-video/' },
                                      '1' => { :prefix => 'http://www.whitehouse.gov/blog/is/deep' } })
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

  describe "#new_user_to_admin" do
    context "affiliate user has .com email address" do
      let(:user) do
        double(User,
             :email => 'not.gov.user@agency.com',
             :contact_name => 'Contractor Joe',
             :affiliates => [],
             :organization_name => 'Agency',
             :requires_manual_approval? => true)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(bcc_setting) }
      it { should have_subject(/New user sign up/) }
      it { should have_body_text(/Name: Contractor Joe\nEmail: not.gov.user@agency.com\nOrganization name: Agency\n\n\n    This person doesn't have a .gov or .mil email address/) }
    end

    context "affiliate user has .gov email address" do
      let(:user) do
        double(User,
             :email => 'not.com.user@agency.gov',
             :contact_name => 'Gov Employee Joe',
             :affiliates => [],
             :organization_name => 'Gov Agency',
             :requires_manual_approval? => false)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(bcc_setting) }
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
      it { should bcc_to(bcc_setting) }
      it { should have_body_text /Name: Invited Affiliate Manager\nEmail: affiliate_added_by_another_affiliate@fixtures.org\nOrganization name: Agency\n\n\n    Affiliate Manager added this person to 'Noaa Site'. He'll be approved after verifying his email./ }
    end

    context "user didn't get invited by another customer (and thus has no affiliates either)" do
      let(:user) do
        double(User,
             :email => 'not.com.user@agency.gov',
             :contact_name => 'Gov Employee Joe',
             :organization_name => 'Gov Agency',
             :affiliates => [],
             :requires_manual_approval? => false)

      end

      subject { Emailer.new_user_to_admin(user) }

      it { should deliver_to('usagov@mail.usasearch.howto.gov') }
      it { should bcc_to(bcc_setting) }
      it { should_not have_body_text /This user was added to affiliate/ }
    end
  end

  describe '#daily_snapshot' do
    let(:membership) { memberships(:four) }
    let(:dashboard) { double(RtuDashboard) }

    before do
      RtuDashboard.stub(:new).with(membership.affiliate, Date.yesterday, membership.user.sees_filtered_totals?).and_return dashboard
      dashboard.stub(:top_queries).and_return [['query1', 100, 80], ['query2', 101, 75], ['query3', 102, 0]]
      dashboard.stub(:top_urls).and_return [['http://www.nps.gov/query3', 8], ['http://www.nps.gov/query2', 7], ['http://www.nps.gov/query1', 6]]
      dashboard.stub(:trending_queries).and_return %w(query3 query2 query1)
      dashboard.stub(:no_results).and_return [QueryCount.new('query3blah', 3), QueryCount.new('query2blah', 2), QueryCount.new('query1blah', 1)]
      dashboard.stub(:low_ctr_queries).and_return [['query1', 6], ['query2', 6], ['query3', 7]]
    end

    subject(:email) { Emailer.daily_snapshot(membership) }

    it { should deliver_to(membership.user.email) }
    it { should have_subject(/Today's Snapshot for #{membership.affiliate.name} on #{Date.yesterday}/) }

    it "should contain the daily shapshot tables for yesterday" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('Top Queries')
      body.should include('Search Term Total Queries (Bots + Humans) Real Queries')
      body.should include('1. query1 100 80')
      body.should include('2. query2 101 75')
      body.should include('3. query3 102 0')

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
    let(:user_monthly_report) { double(UserMonthlyReport) }

    before do
      UserMonthlyReport.stub(:new).and_return user_monthly_report
      as1 = { affiliate: affiliates(:basic_affiliate), total_unfiltered_queries: 102, total_queries: 100, last_month_percent_change: 33.33, last_year_percent_change: -33.33, total_clicks: 100, popular_queries: [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]], popular_clicks: [['click5', 44, 43], ['click6', 45, 33], ['click4', 43, 32]] }
      as2 = { affiliate: affiliates(:power_affiliate), total_unfiltered_queries: 50, total_queries: 40, last_month_percent_change: 12, last_year_percent_change: -9, total_clicks: 35, popular_queries: [['query1', 100, 80], ['query2', 101, 75], ['query3', 102, 0]], popular_clicks: [['click1', 90, 70], ['click2', 91, 65], ['click3', 92, 2]] }
      as3 = { affiliate: affiliates(:spanish_affiliate), total_unfiltered_queries: 0, total_queries: 0, last_month_percent_change: 0, last_year_percent_change: 0, total_clicks: 0, popular_queries: RtuQueryRawHumanArray::INSUFFICIENT_DATA, popular_clicks: RtuClickRawHumanArray::INSUFFICIENT_DATA }
      total = { total_unfiltered_queries: 152, total_queries: 140, last_month_percent_change: 24, last_year_percent_change: -29, total_clicks: 135 }
      user_monthly_report.stub(:report_date).and_return report_date
      affiliate_stats = { affiliates(:basic_affiliate).name => as1, affiliates(:power_affiliate).name => as2, affiliates(:spanish_affiliate).name => as3 }
      user_monthly_report.stub(:affiliate_stats).and_return affiliate_stats
      user_monthly_report.stub(:total_stats).and_return total
    end

    subject(:email) { Emailer.affiliate_monthly_report(user, report_date) }

    it { should deliver_to(user.email) }
    it { should bcc_to(bcc_setting) }
    it { should have_subject(/April 2012/) }

    it "should show per-affiliate and total stats for the month" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('102 100 33.33% -33.33% 100')
      body.should include('50 40 12.00% -9.00% 35')
      body.should include('0 0 0.00% 0.00% 0')
      body.should include('152 140 24.00% -29.00% 135')
      body.should include('Top 10 Searches for April 2012')
      body.should include('NPEspanol Site Not enough historic data to compute most popular')
      body.should include('query1 100 80')
      body.should include('query2 101 75')
      body.should include('query3 102 0')
      body.should include('query5 54 53')
      body.should include('query6 55 43')
      body.should include('query4 53 42')
    end
  end

  describe "#affiliate_yearly_report" do
    let(:user) { users(:affiliate_manager) }
    let(:report_year) { 2012 }

    before do
      affiliate = affiliates(:basic_affiliate)
      report_date = Date.civil(report_year, 1, 1)
      nps_top_queries = [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]]
      insufficient = RtuQueryRawHumanArray::INSUFFICIENT_DATA
      RtuQueryRawHumanArray.stub(:new).and_return double(RtuQueryRawHumanArray, top_queries: insufficient)
      RtuQueryRawHumanArray.stub(:new).with('nps.gov', Date.parse("2012-01-01"), Date.parse("2012-12-31"), 100).and_return double(RtuQueryRawHumanArray, top_queries: nps_top_queries)
    end

    subject(:email) { Emailer.affiliate_yearly_report(user, report_year) }

    it { should deliver_to(user.email) }
    it { should bcc_to(bcc_setting) }
    it { should have_subject(/2012 Year in Review/) }

    it "show stats for the year" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      body.should include('Most Popular Queries for 2012')
      body.should include('NPEspanol Site Not enough historic data to compute most popular')
      body.should include('query5 54 53')
      body.should include('query6 55 43')
      body.should include('query4 53 42')
    end
  end

  describe '#update_external_tracking_code' do
    let(:affiliate) { mock_model(Affiliate, display_name: 'Search.gov') }
    let(:current_user) { mock_model(User, email: 'admin@agency.gov') }
    let(:tracking_code) { 'var foo = "bar"'.freeze }

    subject(:email) { Emailer.update_external_tracking_code(affiliate, current_user, tracking_code) }

    it { should deliver_from(Emailer::NOTIFICATION_SENDER_EMAIL_ADDRESS) }
    it { should deliver_to(SUPPORT_EMAIL_ADDRESS) }
    it { should_not reply_to(Emailer::REPLY_TO_EMAIL_ADDRESS) }
    it { should have_body_text tracking_code }
  end

  describe '#user_sites' do
    let(:user) { mock_model(User, email: 'admin@agency.gov') }
    let(:sites) { [affiliates(:basic_affiliate)] }

    subject(:email) { Emailer.user_sites(user, sites) }

    it { should deliver_to(user.email) }
    it { should bcc_to(bcc_setting) }
    it { should reply_to(Emailer::REPLY_TO_EMAIL_ADDRESS) }
    it { should have_body_text sites.first.display_name }
  end

  context "when a template is missing" do
    let(:user) { double(User, :email => "invitee@agency.com", :contact_name => 'Invitee Joe', :email_verification_token => 'some_special_token', affiliates: []) }
    let(:report_date) { Date.today }

    before { EmailTemplate.destroy_all }

    subject { Emailer.affiliate_monthly_report(user, report_date) }

    it { should deliver_to(bcc_setting) }
    it { should have_subject('[Search.gov] Missing Email template') }
    it { should have_body_text(/Someone tried to send an email via the affiliate_monthly_report method, but we don\'t have a template for that method.  Please create one.  Thanks!/) }

    after { EmailTemplate.load_default_templates }
  end
end

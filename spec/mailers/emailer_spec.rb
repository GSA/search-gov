require 'spec_helper'

describe Emailer do
context do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :users, :features, :memberships

  describe '#user_approval_removed' do
    let(:user) { users(:another_affiliate_manager) }

    subject(:email) { Emailer.user_approval_removed(user) }

    it { is_expected.to deliver_to("usagov@search.gov") }
    it { is_expected.to have_body_text "The following user is no longer associated with any sites" }
    it { is_expected.to have_body_text user.contact_name }
    it { is_expected.to have_body_text user.email }
    it { is_expected.to have_body_text user.organization_name }
  end

  describe "#new_feature_adoption_to_admin" do
    before do
      AffiliateFeatureAddition.delete_all
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:disco))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:basic_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:sayt))
      AffiliateFeatureAddition.create!(:affiliate => affiliates(:power_affiliate), :feature => features(:disco), :created_at => 2.days.ago)
    end

    subject(:email) { Emailer.new_feature_adoption_to_admin.deliver_now }

    it { is_expected.to deliver_to('usagov@search.gov') }
    it { is_expected.to have_subject(/Features adopted yesterday/) }

    it 'should contain lists of newly adopted features for each affiliate that has any' do
      expect(email).to have_body_text("Yesterday, these customers turned on some features:")
      expect(email).to have_body_text("NPS Site (nps.gov):\nDiscovery Tag\nSAYT")
      expect(email).to have_body_text("Noaa Site (noaa.gov):\nSAYT")
    end
  end

  describe "#deep_collection_notification" do
    let(:document_collection) do
      affiliates(:basic_affiliate).document_collections.create!(
        :name => 'WH only',
        :url_prefixes_attributes => { '0' => { :prefix => 'http://www.whitehouse.gov/photos-and-video/' },
                                      '1' => { :prefix => 'http://www.whitehouse.gov/blog/is/deep' } })
    end

    subject(:email) { Emailer.deep_collection_notification(users(:affiliate_manager), document_collection).deliver_now }

    it { is_expected.to deliver_to('usagov@search.gov') }
    it { is_expected.to have_subject(/Deep collection created/) }

    it 'should contain document collection and URL prefixes' do
      expect(email).to have_body_text("WH only")
      expect(email).to have_body_text('http://www.whitehouse.gov/photos-and-video/')
      expect(email).to have_body_text('http://www.whitehouse.gov/blog/is/deep')
    end
  end

  describe "#filtered_popular_terms_report" do
    subject(:email) { Emailer.filtered_popular_terms_report(%w{foo bar blat}).deliver_now }

    it { is_expected.to deliver_to('usagov@search.gov') }
    it { is_expected.to have_subject(/Filtered Popular Terms for Last Week/) }

    it 'should contain list of filtered sayt suggestions' do
      expect(email).to have_body_text("foo")
      expect(email).to have_body_text("bar")
      expect(email).to have_body_text("blat")
    end
  end

  describe "#user_email_verification" do
    let(:user) { mock_model(User, :email => 'admin@agency.gov', :contact_name => 'Admin', :email_verification_token => 'some_special_token') }

    subject { Emailer.user_email_verification(user).deliver }

    it { should deliver_to('admin@agency.gov') }
    it { should have_subject(/Verify your email/) }
    it { should have_body_text(/https:\/\/localhost:3000\/email_verification\/some_special_token/) }
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

      it { is_expected.to deliver_to('usagov@search.gov') }
      it { is_expected.to have_subject(/New user sign up/) }
      it { is_expected.to have_body_text(/Name: Contractor Joe\nEmail: not.gov.user@agency.com\nOrganization name: Agency\n\n\n    This person doesn't have a .gov or .mil email address/) }
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

      it { is_expected.to deliver_to('usagov@search.gov') }
      it { is_expected.to have_subject(/New user sign up/) }
      it { is_expected.not_to have_body_text /This user signed up as an affiliate/ }
    end

    context 'user got invited by another customer' do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }

      before do
        user.affiliates << affiliates(:gobiernousa_affiliate)
        user.affiliates << affiliates(:power_affiliate)
        user.save!
        user.reload
        user.inviter = users(:affiliate_manager)
      end

      subject { Emailer.new_user_to_admin(user) }

      it { is_expected.to deliver_to('usagov@search.gov') }
      it { is_expected.to have_body_text /Name: Invited Affiliate Manager\nEmail: affiliate_added_by_another_affiliate@fixtures.org\nOrganization name: Agency\n\n\n    Affiliate Manager added this person to 'Noaa Site'. They will be approved after verifying their email./ }
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

      it { is_expected.to deliver_to('usagov@search.gov') }
      it { is_expected.not_to have_body_text /This user was added to affiliate/ }
    end
  end

  describe "#welcome_to_new_user_added_by_affiliate" do
    let(:user) do
      mock_model(User,
                 email: 'invitee@agency.com',
                 contact_name: 'Invitee Joe')
    end

    let(:current_user) { mock_model(User, :email => "inviter@agency.com", :contact_name => 'Inviter Jane') }
    let(:affiliate) { affiliates(:basic_affiliate) }

    subject { Emailer.welcome_to_new_user_added_by_affiliate(affiliate, user, current_user) }

    it { should deliver_to("invitee@agency.com") }
    it { should have_subject(/\[Search.gov\] Welcome to Search.gov/) }
    it { should have_body_text(/https:\/\/localhost:3000\/sites/) }
  end

  describe '#daily_snapshot' do
    let(:membership) { memberships(:four) }
    let(:dashboard) { double(RtuDashboard) }

    before do
      allow(RtuDashboard).to receive(:new).with(membership.affiliate, Date.yesterday, membership.user.sees_filtered_totals?).and_return dashboard
      allow(dashboard).to receive(:top_queries).and_return [['query1', 100, 80], ['query2', 101, 75], ['query3', 102, 0]]
      allow(dashboard).to receive(:top_urls).and_return [['http://www.nps.gov/query3', 8], ['http://www.nps.gov/query2', 7], ['http://www.nps.gov/query1', 6]]
      allow(dashboard).to receive(:trending_queries).and_return %w(query3 query2 query1)
      allow(dashboard).to receive(:no_results).and_return [QueryCount.new('query3blah', 3), QueryCount.new('query2blah', 2), QueryCount.new('query1blah', 1)]
      allow(dashboard).to receive(:low_ctr_queries).and_return [['query1', 6], ['query2', 6], ['query3', 7]]
    end

    subject(:email) { Emailer.daily_snapshot(membership) }

    it { is_expected.to deliver_to(membership.user.email) }
    it { is_expected.to have_subject(/Today's Snapshot for #{membership.affiliate.name} on #{Date.yesterday}/) }

    it "should contain the daily shapshot tables for yesterday" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      expect(body).to include('Top Queries')
      expect(body).to include('Search Term Total Queries (Bots + Humans) Real Queries')
      expect(body).to include('1. query1 100 80')
      expect(body).to include('2. query2 101 75')
      expect(body).to include('3. query3 102 0')

      expect(body).to include('Top Clicked URLs')
      expect(body).to include('URL # of Clicks')
      expect(body).to include('1. http://www.nps.gov/query3 8')
      expect(body).to include('2. http://www.nps.gov/query2 7')
      expect(body).to include('3. http://www.nps.gov/query1 6')

      expect(body).to include('Trending Queries')
      expect(body).to include('query3')
      expect(body).to include('query2')
      expect(body).to include('query1')

      expect(body).to include('Queries with No Results')
      expect(body).to include('Query # of Queries')
      expect(body).to include('1. query3blah 3')
      expect(body).to include('2. query2blah 2')
      expect(body).to include('3. query1blah 1')

      expect(body).to include('Top Queries with Low Click Thrus')
      expect(body).to include('Query CTR %')
      expect(body).to include('1. query1 6%')
      expect(body).to include('2. query2 6%')
      expect(body).to include('3. query3 7%')
    end
  end

  describe "#affiliate_monthly_report" do
    let(:user) { users(:affiliate_manager) }
    let(:report_date) { Date.parse('2012-04-13') }
    let(:user_monthly_report) { double(UserMonthlyReport) }

    before do
      allow(UserMonthlyReport).to receive(:new).and_return user_monthly_report
      as1 = { affiliate: affiliates(:basic_affiliate), total_unfiltered_queries: 102, total_queries: 100, last_month_percent_change: 33.33, last_year_percent_change: -33.33, total_clicks: 100, popular_queries: [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]], popular_clicks: [['click5', 44, 43], ['click6', 45, 33], ['click4', 43, 32]] }
      as2 = { affiliate: affiliates(:power_affiliate), total_unfiltered_queries: 50, total_queries: 40, last_month_percent_change: 12, last_year_percent_change: -9, total_clicks: 35, popular_queries: [['query1', 100, 80], ['query2', 101, 75], ['query3', 102, 0]], popular_clicks: [['click1', 90, 70], ['click2', 91, 65], ['click3', 92, 2]] }
      as3 = { affiliate: affiliates(:spanish_affiliate), total_unfiltered_queries: 0, total_queries: 0, last_month_percent_change: 0, last_year_percent_change: 0, total_clicks: 0, popular_queries: RtuQueryRawHumanArray::INSUFFICIENT_DATA, popular_clicks: RtuClickRawHumanArray::INSUFFICIENT_DATA }
      total = { total_unfiltered_queries: 152, total_queries: 140, last_month_percent_change: 24, last_year_percent_change: -29, total_clicks: 135 }
      allow(user_monthly_report).to receive(:report_date).and_return report_date
      affiliate_stats = { affiliates(:basic_affiliate).name => as1, affiliates(:power_affiliate).name => as2, affiliates(:spanish_affiliate).name => as3 }
      allow(user_monthly_report).to receive(:affiliate_stats).and_return affiliate_stats
      allow(user_monthly_report).to receive(:total_stats).and_return total
    end

    subject(:email) { Emailer.affiliate_monthly_report(user, report_date) }

    it { is_expected.to deliver_to(user.email) }
    it { is_expected.to have_subject(/April 2012/) }

    it "should show per-affiliate and total stats for the month" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      expect(body).to include('102 100 33.33% -33.33% 100')
      expect(body).to include('50 40 12.00% -9.00% 35')
      expect(body).to include('0 0 0.00% 0.00% 0')
      expect(body).to include('152 140 24.00% -29.00% 135')
      expect(body).to include('Top 10 Searches for April 2012')
      expect(body).to include('NPEspanol Site Not enough historic data to compute most popular')
      expect(body).to include('query1 100 80')
      expect(body).to include('query2 101 75')
      expect(body).to include('query3 102 0')
      expect(body).to include('query5 54 53')
      expect(body).to include('query6 55 43')
      expect(body).to include('query4 53 42')
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
      allow(RtuQueryRawHumanArray).to receive(:new).and_return double(RtuQueryRawHumanArray, top_queries: insufficient)
      allow(RtuQueryRawHumanArray).to receive(:new).with('nps.gov', Date.parse("2012-01-01"), Date.parse("2012-12-31"), 100).and_return double(RtuQueryRawHumanArray, top_queries: nps_top_queries)
    end

    subject(:email) { Emailer.affiliate_yearly_report(user, report_year) }

    it { is_expected.to deliver_to(user.email) }
    it { is_expected.to have_subject(/2012 Year in Review/) }

    it "show stats for the year" do
      body = Sanitize.clean(email.default_part_body.to_s).squish
      expect(body).to include('Most Popular Queries for 2012')
      expect(body).to include('NPEspanol Site Not enough historic data to compute most popular')
      expect(body).to include('query5 54 53')
      expect(body).to include('query6 55 43')
      expect(body).to include('query4 53 42')
    end
  end

  describe '#update_external_tracking_code' do
    let(:affiliate) { mock_model(Affiliate, display_name: 'Search.gov') }
    let(:current_user) { mock_model(User, email: 'admin@agency.gov') }
    let(:tracking_code) { 'var foo = "bar"'.freeze }

    subject(:email) { Emailer.update_external_tracking_code(affiliate, current_user, tracking_code) }

    it { is_expected.to deliver_from(Emailer::NOTIFICATION_SENDER_EMAIL_ADDRESS) }
    it { is_expected.to deliver_to(Rails.application.secrets.organization[:support_email_address]) }
    it { is_expected.not_to reply_to(Emailer::REPLY_TO_EMAIL_ADDRESS) }
    it { is_expected.to have_body_text tracking_code }
  end

  describe '#user_sites' do
    let(:user) { mock_model(User, email: 'admin@agency.gov') }
    let(:sites) { [affiliates(:basic_affiliate)] }

    subject(:email) { Emailer.user_sites(user, sites) }

    it { is_expected.to deliver_to(user.email) }
    it { is_expected.to reply_to(Emailer::REPLY_TO_EMAIL_ADDRESS) }
    it { is_expected.to have_body_text sites.first.display_name }
  end

  context "when a template is missing" do
    let(:user) { double(User, :email => "invitee@agency.com", :contact_name => 'Invitee Joe', :email_verification_token => 'some_special_token', affiliates: []) }
    let(:report_date) { Date.today }

    before { EmailTemplate.destroy_all }

    subject { Emailer.affiliate_monthly_report(user, report_date) }

    it { is_expected.to deliver_to(Emailer::ADMIN_EMAIL_ADDRESS) }
    it { is_expected.to have_subject('[Search.gov] Missing Email template') }
    it { is_expected.to have_body_text(/Someone tried to send an email via the affiliate_monthly_report method, but we don\'t have a template for that method.  Please create one.  Thanks!/) }

    after { EmailTemplate.load_default_templates }
  end
end
end

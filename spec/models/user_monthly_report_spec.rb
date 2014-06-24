require 'spec_helper'

describe UserMonthlyReport do
  fixtures :affiliates, :users, :memberships

  let(:user) { users(:affiliate_manager) }
  let(:report_date) { Date.parse('2014-05-01') }
  let(:user_monthly_report) { UserMonthlyReport.new(user, report_date) }
  let(:popular_queries) { [QueryCount.new('query6', 55), QueryCount.new('query5', 54), QueryCount.new('query4', 53)] }

  before do
    user.affiliates = [affiliates(:basic_affiliate)]
    RtuMonthlyReport.stub(:new).and_return mock(RtuMonthlyReport, total_queries: 100, total_clicks: 50)
    RtuQueryStat.stub(:most_popular_human_searches).and_return popular_queries
    DailyUsageStat.stub(:monthly_totals).with(2014, 4, affiliates(:basic_affiliate).name).and_return 100
    DailyUsageStat.stub(:monthly_totals).with(2013, 5, affiliates(:basic_affiliate).name).and_return 1000
  end

  it 'should assign the report date' do
    user_monthly_report.report_date.should == report_date
  end

  it 'should assign the affiliate stats' do
    stats = { :affiliate => affiliates(:basic_affiliate), :total_queries => 100, :total_clicks => 50, :last_month_total_queries => 100, :last_year_total_queries => 1000, :last_month_percent_change => 0.0, :last_year_percent_change => -90.0, :popular_queries => popular_queries }
    user_monthly_report.affiliate_stats.should == { "nps.gov" => stats }
  end

  it 'should assign the total stats' do
    stats = { :total_queries => 100, :total_clicks => 50, :last_month_total_queries => 100, :last_year_total_queries => 1000, :last_month_percent_change => 0.0, :last_year_percent_change => -90.0 }
    user_monthly_report.total_stats.should == stats
  end
end
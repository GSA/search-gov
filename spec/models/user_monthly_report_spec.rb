require 'spec_helper'

describe UserMonthlyReport do
  fixtures :affiliates, :users, :memberships

  let(:user) { users(:affiliate_manager) }
  let(:report_date) { Date.parse('2014-05-01') }
  let(:user_monthly_report) { UserMonthlyReport.new(user, report_date) }
  let(:popular_queries) { [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]] }
  let(:popular_clicks) { [['click5', 44, 43], ['click6', 45, 33], ['click4', 43, 32]] }

  before do
    user.affiliates = [affiliates(:basic_affiliate)]
    allow(RtuMonthlyReport).to receive(:new).and_return(double(RtuMonthlyReport, total_queries: 102, total_clicks: 52),
                                           double(RtuMonthlyReport, total_queries: 100, total_clicks: 50),
                                           double(RtuMonthlyReport, total_queries: 80, total_clicks: 40),
                                           double(RtuMonthlyReport, total_queries: 1000, total_clicks: 1000))
    allow(RtuQueryRawHumanArray).to receive(:new).and_return double(RtuQueryRawHumanArray, top_queries: popular_queries)
    allow(RtuClickRawHumanArray).to receive(:new).and_return double(RtuClickRawHumanArray, top_clicks: popular_clicks)
  end

  it 'should assign the report date' do
    expect(user_monthly_report.report_date).to eq(report_date)
  end

  it 'should assign the affiliate stats' do
    stats = { :affiliate => affiliates(:basic_affiliate), :total_unfiltered_queries => 102, :total_queries => 100, :total_clicks => 50, :last_month_total_queries => 80, :last_year_total_queries => 1000, :last_month_percent_change => 25.0, :last_year_percent_change => -90.0, :popular_queries => popular_queries, :popular_clicks => popular_clicks }
    expect(user_monthly_report.affiliate_stats).to eq({ "nps.gov" => stats })
  end

  it 'should assign the total stats' do
    stats = { :total_unfiltered_queries => 102, :total_queries => 100, :total_clicks => 50, :last_month_total_queries => 80, :last_year_total_queries => 1000, :last_month_percent_change => 25.0, :last_year_percent_change => -90.0 }
    expect(user_monthly_report.total_stats).to eq(stats)
  end
end

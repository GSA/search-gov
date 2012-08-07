require 'spec_helper'

describe DailyQueryNoresultsStat do
  fixtures :daily_query_noresults_stats, :affiliates
  before(:each) do
    @valid_attributes = {
      :day => Date.current,
      :query => "nothing found",
      :times => 11,
      :affiliate => 'usagov'
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :affiliate }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate]) }

    it "should create a new instance given valid attributes" do
      DailyQueryNoresultsStat.create!(@valid_attributes)
    end
  end

  describe "most_popular_no_results_queries" do
    before do
      DailyQueryNoresultsStat.create!(:day => Date.yesterday, :query => 'obama', :times => 10, :affiliate => affiliates(:usagov_affiliate).name)
      DailyQueryNoresultsStat.create!(:day => Date.yesterday - 1.days, :query => 'obama', :times => 10, :affiliate => affiliates(:usagov_affiliate).name)
      DailyQueryNoresultsStat.create!(:day => Date.yesterday - 100.days, :query => 'obama', :times => 10, :affiliate => affiliates(:usagov_affiliate).name)
      DailyQueryNoresultsStat.create!(:day => Date.yesterday, :query => 'obama', :times => 10, :affiliate => affiliates(:gobiernousa_affiliate).name)
    end

    it "should return an array of QueryCounts summing up the most popular no-results queries for the given date range" do
      results = DailyQueryNoresultsStat.most_popular_no_results_queries(Date.yesterday - 3.days, Date.yesterday, 10, 'usagov')
      results.is_a?(Array).should be_true
      results.size.should == 1
      results.first.is_a?(QueryCount).should be_true
      results.first.query.should == "obama"
      results.first.times.should == 20
    end
  end
end
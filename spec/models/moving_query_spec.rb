require 'spec/spec_helper'

describe MovingQuery do
  fixtures :moving_queries
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314,
      :mean => 100.01,
      :std_dev => 4.3
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_uniqueness_of(:query).scoped_to(:day) }

    it "should create a new instance given valid attributes" do
      MovingQuery.create!(@valid_attributes)
    end
  end

  describe "#compute_for" do
    context "when query terms get an unusually large number of queries for a given day" do
      before do
        DailyQueryStat.delete_all
        MovingQuery.delete_all
        # received zero queries per day for these terms since Jan 1 2009 except for these:
        DailyQueryStat.create!(:day => Date.yesterday, :times => 100000, :query => "1-day", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :times => 200000, :query => "1-day", :locale => 'es')
        DailyQueryStat.create!(:day => Date.yesterday, :times => 300000, :query => "1-day", :affiliate => 'noaa.gov')
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
      end

      it "should find and create 1-day moving queries for the given day by combining locales and affiliates" do
        MovingQuery.find_by_day_and_query(Date.yesterday, "1-day").times.should == 600000
      end
    end

    context "when an English locale query for usasearch.gov gets roughly the same amount of queries it normally gets for a given day" do
      before do
        Date.new(2009, 5, 10).upto(Date.new(2009, 6, 1)) { |day| DailyQueryStat.create!(:day => day.to_date, :times => 10 + rand(5), :query => "usual", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)}
        @target_date = Date.new(2009, 6, 2)
        DailyQueryStat.create!(:day => @target_date, :times => 16, :query => "usual", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should not create any moving query records for that query on that day" do
        MovingQuery.compute_for(@target_date)
        MovingQuery.find_by_day_and_query(@target_date, "usual").should be_nil
      end
    end

    context "when a brand new query (i.e., zero searches since Jan 1 2009) gets 16 searches per day for the 14th day in a row" do
      before do
        DailyQueryStat.delete_all
        14.days.ago.to_date.upto(Date.yesterday) { |day| DailyQueryStat.create!(:day => day.to_date, :times => 16, :query => "still accelerating?", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)}
      end

      it "should not create a 1-day moving query for the query" do
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
        MovingQuery.find_by_day_and_query(Date.yesterday, "still accelerating?").should be_nil
      end

      context "when there is similar data for an affiliate" do
        before do
          14.days.ago.to_date.upto(Date.yesterday) { |day| DailyQueryStat.create!(:day => day.to_date, :times => 16, :query => "still accelerating?", :affiliate => 'affiliate.gov')}
        end

        it "should not create a 1-day moving query for the query" do
          MovingQuery.compute_for(Date.yesterday.to_s(:number))
          MovingQuery.find_by_day_and_query(Date.yesterday, "still accelerating?").should be_nil
        end
      end
    end

    context "when a brand new query (i.e., zero searches since Jan 1 2009) gets 40 searches one day followed by 30, 22, 21, 20, and 16 searches" do
      before do
        DailyQueryStat.delete_all
        ary = [40, 30, 22, 21, 20, 16]
        idx = 0
        ary.size.days.ago.to_date.upto(Date.yesterday) do |day|
          DailyQueryStat.create!(:day => day.to_date, :times => ary[idx], :query => "still accelerating?", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
          idx+=1
        end
      end

      it "should not create a 1-day moving query for the query" do
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
        MovingQuery.find_by_day_and_query(Date.yesterday, "still accelerating?").should be_nil
      end
    end
  end

  describe "#passes_minimum_thresholds?" do
    it "should return true when the MovingQuery exceeds thresholds for deviation from mean and number of queries for a given time window" do
      MovingQuery.new(:query=> "query", :day => Date.current, :times => 16, :mean => 11.9, :std_dev => 1.0).passes_minimum_thresholds?.should be_true
      MovingQuery.new(:query=> "query", :day => Date.current, :times => 16, :mean => 12.1, :std_dev => 1.0).passes_minimum_thresholds?.should be_false
    end
  end

  describe '#biggest_movers' do
    context "when the table is populated" do
      before do
        MovingQuery.delete_all
        MovingQuery.create!(:query=> "earliest data", :day => Date.new(2009,1,1), :times => 16, :mean => 11.9, :std_dev => 1.0)
        @day = Date.new(2009, 7, 21).to_date
        MovingQuery.create!(:query=> "anomaly", :day => @day, :times => 16, :mean => 11.9, :std_dev => 1.0)
        MovingQuery.create!(:query=> "bigger anomaly", :day => @day, :times => 18, :mean => 11.9, :std_dev => 1.0)
      end

      it "should rank biggest movers for the most recent data available based on search popularity" do
        movers = MovingQuery.biggest_movers(@day)
        movers.first.query.should == "bigger anomaly"
        movers.last.query.should == "anomaly"
      end

      it "should use the num_results parameter to determine result set size" do
        MovingQuery.biggest_movers(@day, 1).size.should == 1
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        MovingQuery.delete_all
      end

      it "should return an error string that no queries matched" do
        MovingQuery.biggest_movers(Date.current.to_date).should == "No queries matched"
      end
    end

    context "when there is insufficient data for the time period and window size specified" do
      before do
        MovingQuery.delete_all
        MovingQuery.create!(:query=> "earliest data in table", :day => Date.new(2009,1,1).to_date, :times => 160, :mean => 11.9, :std_dev => 1.0)
        @day = Date.new(2009, 1, 5).to_date
        MovingQuery.create!(:query=> "anomaly but computed with fewer than 7 data points", :day => @day, :times => 160, :mean => 11.9, :std_dev => 1.0)
      end

      it "should return an error string that there is not enough historical data" do
        MovingQuery.biggest_movers(@day).should == "Not enough historic data to compute accelerations"
      end
    end
  end

end

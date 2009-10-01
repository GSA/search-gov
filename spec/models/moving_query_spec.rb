require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MovingQuery do
  fixtures :moving_queries
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :window_size => 7,
      :times => 314,
      :mean => 100.01,
      :std_dev => 4.3
    }
  end

  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :window_size, :times)
    should_validate_uniqueness_of :query, :scope => [:day, :window_size]

    it "should create a new instance given valid attributes" do
      MovingQuery.create!(@valid_attributes)
    end
  end

  describe "#compute_for" do
    context "when query terms get an unusually large number of queries for a given time period" do
      before do
        DailyQueryStat.delete_all
        MovingQuery.delete_all
        # received zero queries per day for these terms sine Jan 1 2009 except for these:
        DailyQueryStat.create!(:day => Date.yesterday, :times => 100000, :query => "1-day")

        DailyQueryStat.create!(:day => 4.days.ago.to_date, :times => 7, :query => "7-day")
        DailyQueryStat.create!(:day => Date.yesterday, :times => 200000, :query => "7-day")

        DailyQueryStat.create!(:day => 3.weeks.ago.to_date, :times => 30, :query => "30-day")
        DailyQueryStat.create!(:day => Date.yesterday, :times => 300000, :query => "30-day")
      end

      it "should find and create 1-, 7-, and 30-day moving queries for the given day" do
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
        MovingQuery.count.should == 9
        [1, 7, 30].each {|win_size| MovingQuery.find_by_day_and_query_and_window_size(Date.yesterday, "1-day", win_size).times.should == 100000 }
        MovingQuery.find_by_day_and_query_and_window_size(Date.yesterday, "7-day", 7).times.should == 200007
        MovingQuery.find_by_day_and_query_and_window_size(Date.yesterday, "30-day", 30).times.should == 300030
      end
    end

    context "when a query gets roughly the same amount of queries it normally gets for a given day, week, and month" do
      before do
        Date.new(2009, 1, 1).upto(Date.new(2009, 6, 1)) { |day| DailyQueryStat.create!(:day => day.to_date, :times => 10 + rand(5), :query => "usual")}
        @target_date = Date.new(2009, 6, 2)
        DailyQueryStat.create!(:day => @target_date, :times => 16, :query => "usual")
      end

      it "should not create any moving query records for that query on that day" do
        MovingQuery.compute_for(@target_date)
        [1, 7, 30].each {|win_size| MovingQuery.find_by_day_and_query_and_window_size(@target_date, "usual", win_size).should be_nil }
      end
    end

    context "when a brand new query (i.e., zero searches since Jan 1 2009) gets 16 searches per day for the 14th day in a row" do
      before do
        DailyQueryStat.delete_all
        14.days.ago.to_date.upto(Date.yesterday) { |day| DailyQueryStat.create!(:day => day.to_date, :times => 16, :query => "still accelerating?")}
      end

      it "should not create a 1-day moving query for the query" do
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
        MovingQuery.find_by_day_and_query_and_window_size(Date.yesterday, "still accelerating?", 1).should be_nil
      end
    end

    context "when a brand new query (i.e., zero searches since Jan 1 2009) gets 40 searches one day followed by 30, 22, 21, 20, and 16 searches" do
      before do
        DailyQueryStat.delete_all
        ary = [40, 30, 22, 21, 20, 16]
        idx = 0
        ary.size.days.ago.to_date.upto(Date.yesterday) do |day|
          DailyQueryStat.create!(:day => day.to_date, :times => ary[idx], :query => "still accelerating?")
          idx+=1
        end
      end

      it "should not create a 1-day moving query for the query" do
        MovingQuery.compute_for(Date.yesterday.to_s(:number))
        MovingQuery.find_by_day_and_query_and_window_size(Date.yesterday, "still accelerating?", 1).should be_nil
      end
    end
  end

  describe "#passes_minimum_thresholds?" do
    it "should return true when the MovingQuery exceeds thresholds for deviation from mean and number of queries for a given time window" do
      MovingQuery.new(:query=> "query", :day => Date.today, :window_size => 1, :times => 16, :mean => 11.9, :std_dev => 1.0).passes_minimum_thresholds?.should be_true
      MovingQuery.new(:query=> "query", :day => Date.today, :window_size => 1, :times => 16, :mean => 12.1, :std_dev => 1.0).passes_minimum_thresholds?.should be_false
    end
  end

  describe '#biggest_movers' do
    context "when the table is populated" do
      before do
        MovingQuery.delete_all
        @day = Date.new(2009, 7, 21).to_date
        MovingQuery.create!(:query=> "anomaly", :day => @day, :window_size => 1, :times => 16, :mean => 11.9, :std_dev => 1.0)
        MovingQuery.create!(:query=> "bigger anomaly", :day => @day, :window_size => 1, :times => 18, :mean => 11.9, :std_dev => 1.0)
      end

      it "should rank biggest movers for the most recent data available based on search popularity" do
        movers = MovingQuery.biggest_movers(@day, 1)
        movers.first.query.should == "bigger anomaly"
        movers.last.query.should == "anomaly"
      end

      it "should use the num_results parameter to determine result set size" do
        MovingQuery.biggest_movers(@day, 1, 1).size.should == 1
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        MovingQuery.delete_all
      end

      it "should return nil" do
        MovingQuery.biggest_movers(Date.today.to_date, 1).should be_nil
      end
    end

    context "when there are query groups and grouped queries in the data" do
      before do
        MovingQuery.delete_all
        @day = Date.new(2009, 7, 21).to_date
        MovingQuery.create!(:query=> "query1", :day => @day, :window_size => 1, :times => 16, :mean => 11.9, :std_dev => 1.0)
        MovingQuery.create!(:query=> "query2", :day => @day, :window_size => 1, :times => 18, :mean => 11.9, :std_dev => 1.0)
        qg = QueryGroup.create!(:name=>"my query group")
        qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
        qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
      end

      it "should roll up grouped queries into a single QueryCount with children" do
        yday = MovingQuery.biggest_movers(@day, 1)
        yday.size.should == 1
        yday.first.query.should == "my query group"
        yday.first.times.should == 34
        kids = yday.first.children
        kids.should_not be_nil
        kids.first.query.should == "query2"
        kids.first.times.should == 18
        kids.last.query.should == "query1"
        kids.last.times.should == 16
      end
    end
  end

end

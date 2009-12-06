require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyQueryStat do
  fixtures :daily_query_stats
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314
    }
  end

  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :times)
    should_validate_uniqueness_of :query, :scope => :day

    it "should create a new instance given valid attributes" do
      DailyQueryStat.create!(@valid_attributes)
    end
  end

  describe "#reversed_backfilled_series_since_2009_for" do
    context "when no target date is passed in" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1, :query => "most recent day processed")
        DailyQueryStat.create!(:day => Date.yesterday - 1.day, :times => 1, :query => "outlier")
        @ary = DailyQueryStat.reversed_backfilled_series_since_2009_for("outlier")
      end

      it "should return an array of query counts in reverse day order for a given query" do
        @ary[1].should == 1
      end

      it "should return an array of query counts for every day since Jan 1 2009 thru yesterday, filling in zeros where there is no data for a given day" do
        @ary[0].should == 0
        num_days = 1 + (Date.yesterday - Date.new(2009, 1, 1)).to_i
        @ary.size.should == num_days
        all_but_two = num_days - 2
        target = Array.new(all_but_two).fill(0)
        @ary[2, all_but_two].should == target
      end
    end

    context "when a target date is passed in" do
      before do
        DailyQueryStat.delete_all
        @day = Date.new(2009, 7, 21).to_date
        DailyQueryStat.create!(:day => @day, :times => 1, :query => "outlier")
        @ary = DailyQueryStat.reversed_backfilled_series_since_2009_for("outlier", @day)
      end

      it "should return an array of query counts for every day since Jan 1 2009 thru the target date" do
        @ary[0].should == 1
        num_days = 1 + (@day - Date.new(2009, 1, 1)).to_i
        @ary.size.should == num_days
      end
    end
  end

  describe '#most_popular_terms_like' do
    before do
      DailyQueryStat.delete_all
      DailyQueryStat.create!(:day => Date.yesterday, :query => "social security", :times => 2 )
      DailyQueryStat.create!(:day => Date.today, :query => "social security", :times => 2 )

      DailyQueryStat.create!(:day => Date.yesterday, :query => "social securities", :times => 1 )
      DailyQueryStat.create!(:day => Date.yesterday, :query => "not a match", :times => 1 )
    end

    it "should show exact matches for search query term grouped on term and sorted by decreasing sum of frequency counts" do
      results = DailyQueryStat.most_popular_terms_like("social security", true)
      results.size.should == 1
      results_array = results.to_a
      results_array[0][0].should == "social security"
      results_array[0][1].should == 4
    end

    it "should show match initial substrings for search query term" do
      results = DailyQueryStat.most_popular_terms_like("social sec", true)
      results.size.should == 2
      results_array = results.to_a
      results_array[0][0].should == "social security"
      results_array[0][1].should == 4
      results_array[1][0].should == "social securities"
      results_array[1][1].should == 1
    end

    it "should show match any substring for search query term" do
      results = DailyQueryStat.most_popular_terms_like("urity", false)
      results.size.should == 1
      results_array = results.to_a
      results_array[0][0].should == "social security"
      results_array[0][1].should == 4
    end

    it "should return empty results when there is no match" do
      results = DailyQueryStat.most_popular_terms_like("foobar", true)
      results.should be_empty
    end
  end

  describe '#most_popular_terms' do
    context "when the table is populated" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 9 )
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 2 )
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 1 )
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 4 )
      end

      it "should calculate popularity sums based on the target date and number of days parameter" do
        yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1)
        yday.first.query.should == "recent day most popular"
        yday.first.times.should == 4
        twodaysago = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 2)
        twodaysago.first.query.should == "older most popular"
        twodaysago.first.times.should == 10
      end

      it "should use the num_results parameter to determine result set size" do
        DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1, 1).size.should == 1
      end
    end

    context "when the table has no data for the time period specified" do
      before do
        DailyQueryStat.delete_all
      end

      it "should return an error string that no queries matched" do
        DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1).should == "Not enough historic data to compute most popular"
      end
    end

    context "when there are query groups and grouped queries in the data" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 100 )
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 10 )
        qg = QueryGroup.create!(:name=>"my query group")
        qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
        qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
      end

      it "should roll up grouped queries into a single QueryCount with children" do
        yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1)
        yday.size.should == 1
        yday.first.query.should == "my query group"
        yday.first.times.should == 110
        kids = yday.first.children
        kids.should_not be_nil
        kids.first.query.should == "query1"
        kids.first.times.should == 100
        kids.last.query.should == "query2"
        kids.last.times.should == 10
      end
    end
  end

  describe "#most_recent_populated_date" do
    it "should return the most recent date entered into the table" do
      DailyQueryStat.should_receive(:maximum).with(:day)
      DailyQueryStat.most_recent_populated_date
    end
  end

  describe "#collect_query_group_named" do
    before do
      DailyQueryStat.delete_all
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10 )
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1 )
      qg = QueryGroup.create!(:name=>"my query group")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
    end

    it "should return an array of DailyQueryStats that sums the frequencies for all queries in query group" do
      results = DailyQueryStat.collect_query_group_named("my query group")
      results.size.should == 1
      results.first.day.should == Date.yesterday
      results.first.times.should == 11
    end
  end

end

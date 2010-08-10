require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyQueryStat do
  fixtures :daily_query_stats
  fixtures :affiliates
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314,
      :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME,
      :locale => I18n.default_locale.to_s
    }
  end

  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :times, :affiliate, :locale)
    should_validate_uniqueness_of :query, :scope => [:day, :affiliate, :locale]

    it "should create a new instance given valid attributes" do
      DailyQueryStat.create!(@valid_attributes)
    end

    it "should create a new instance with the default affiliate if none is specified" do
      @valid_attributes.delete(:affiliate)
      DailyQueryStat.create(@valid_attributes).affiliate.should == DailyQueryStat::DEFAULT_AFFILIATE_NAME
    end

    it "should create a new instance with the default locale if none is specified" do
      @valid_attributes.delete(:locale)
      DailyQueryStat.create(@valid_attributes).locale.should == I18n.default_locale.to_s
    end
  end

  describe "#reversed_backfilled_series_since_2009_for" do
    context "when no target date is passed in" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1, :query => "most recent day processed", :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday - 1.day, :times => 1, :query => "outlier", :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1, :query => "most recent day processed", :affiliate => "affiliate.gov")
        DailyQueryStat.create!(:day => Date.yesterday - 1.day, :times => 1, :query => "outlier", :affiliate => 'affiliate.gov')
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
        DailyQueryStat.create!(:day => @day, :times => 1, :query => "outlier", :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        @ary = DailyQueryStat.reversed_backfilled_series_since_2009_for("outlier", @day)
      end

      it "should return an array of query counts for every day since Jan 1 2009 thru the target date" do
        @ary[0].should == 1
        num_days = 1 + (@day - Date.new(2009, 1, 1)).to_i
        @ary.size.should == num_days
      end
    end
  end

  describe '#most_popular_terms' do
    context "when the table is populated" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 9, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 2, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 1, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 4, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "sparse term", :times => 1, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      end

      it "should calculate popularity sums based on the target date and number of days parameter, ignoring terms with a frequency of less than 4" do
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

      context "when data exists for more than the default affiliate" do
        before do
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 10, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 3, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 2, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 5, :affiliate => "other_affiliate")
        end

        it "should use the affiliate parameter if set to scope the results" do
          yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1, 10, "other_affiliate")
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 5
          twodaysago = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 2, 10, "other_affiliate")
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 12
        end
      end

      context "when a very small amount of affiliate data exists" do
        before do
          DailyQueryStat.create!(:day => Date.yesterday, :query => "sparse term", :times => 1, :affiliate => "tiny_affiliate")
        end

        it "should return those results for affiliates" do
          most_popular_terms = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date("tiny_affiliate"), 1, 10, "tiny_affiliate")
          most_popular_terms.class.should == Array
          most_popular_terms.size.should == 1
        end
      end

      context "when data exists for more than one locale" do
        before do
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 20, :affiliate => "usasearch.gov", :locale => 'es')
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 6, :affiliate => "usasearch.gov", :locale => 'es')
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 4, :affiliate => "usasearch.gov", :locale => 'es')
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 10, :affiliate => "usasearch.gov", :locale => 'es')
        end

        it "should use the default locale when not specified" do
          yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1)
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 4
          twodaysago = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 2)
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 10
        end

        it "should use the locale parameter if set to scope the results" do
          yday = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 1, 10, DailyQueryStat::DEFAULT_AFFILIATE_NAME, 'es')
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 10
          twodaysago = DailyQueryStat.most_popular_terms(DailyQueryStat.most_recent_populated_date, 2, 10, DailyQueryStat::DEFAULT_AFFILIATE_NAME, 'es')
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 24
        end
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
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 100, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 10, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 100, :affiliate => 'affiliate.gov')
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 10, :affiliate => 'affiliate.gov')
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
    it "should return the most recent date entered into the table for the default affiliate and locale" do
      DailyQueryStat.should_receive(:maximum).with(:day, :conditions => ['affiliate = ? AND locale = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME, I18n.default_locale.to_s])
      DailyQueryStat.most_recent_populated_date
    end

    it "should return the most recent date for an affiliate if an affiliate is passed in" do
      DailyQueryStat.should_receive(:maximum).with(:day, :conditions => ['affiliate = ? AND locale = ?', 'nps.gov', I18n.default_locale.to_s])
      DailyQueryStat.most_recent_populated_date('nps.gov')
    end

    it "should return the most recent date for a locale if specified" do
      DailyQueryStat.should_receive(:maximum).with(:day, :conditions => ['affiliate = ? AND locale = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME, 'es'])
      DailyQueryStat.most_recent_populated_date('usasearch.gov', 'es')
    end
  end

  describe "#collect_query_group_named" do
    before do
      DailyQueryStat.delete_all
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 10, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :locale => 'es')
      DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 1, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :locale => 'es')
      qg = QueryGroup.create!(:name=>"my query group")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
    end

    it "should return an array of DailyQueryStats that sums the frequencies for all queries in query group, ignoring other affiliates and locales" do
      results = DailyQueryStat.collect_query_group_named("my query group")
      results.size.should == 1
      results.first.day.should == Date.yesterday
      results.first.times.should == 11
    end
    
    context "when one of the queries has a single quote in it" do
      before do
        DailyQueryStat.create(:query => "jobs", :day => Date.yesterday, :times => 20, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :locale => 'en')
        DailyQueryStat.create(:query => "job's", :day => Date.yesterday, :times => 25, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :locale => 'en')
        query_group = QueryGroup.create!(:name => 'group2')
        query_group.grouped_queries << GroupedQuery.create!(:query => "jobs")
        query_group.grouped_queries << GroupedQuery.create!(:query => "job's")
      end
      
      it "should return results normally" do
        results = DailyQueryStat.collect_query_group_named("group2")
        results.size.should == 1
        results.first.day.should == Date.yesterday
        results.first.times.should == 45
      end
    end 
  end

end

require 'spec/spec_helper'

describe DailyQueryStat do
  fixtures :daily_query_stats, :affiliates
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314,
      :affiliate => Affiliate::USAGOV_AFFILIATE_NAME,
      :locale => I18n.default_locale.to_s
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :locale }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate, :locale]) }

    it "should create a new instance given valid attributes" do
      DailyQueryStat.create!(@valid_attributes)
    end

    it "should create a new instance with the default affiliate if none is specified" do
      @valid_attributes.delete(:affiliate)
      DailyQueryStat.create(@valid_attributes).affiliate.should == Affiliate::USAGOV_AFFILIATE_NAME
    end

    it "should create a new instance with the default locale if none is specified" do
      @valid_attributes.delete(:locale)
      DailyQueryStat.create(@valid_attributes).locale.should == I18n.default_locale.to_s
    end

    context "when queries have extra internal whitespace and/or external whitespace" do
      before do
        @unsquished_query = '  this query  should be   squished.  '
        @squished_query = 'this query should be squished.'
      end

      it "should remove extra interal whitespace and strip whitespace off the ends on create" do
        DailyQueryStat.create(@valid_attributes.merge(:query => @unsquished_query)).query.should == @squished_query
      end

      it "should remove extra internal whitespace and strip whitespace off the ends on update" do
        daily_query_stat = DailyQueryStat.create(@valid_attributes.merge(:query => 'something'))
        daily_query_stat.id.should_not be_nil
        daily_query_stat.update_attributes(:query => @unsquished_query)
        daily_query_stat.query.should == @squished_query
      end
    end
  end

  describe "#reversed_backfilled_series_since_2009_for" do
    context "when no target date is passed in" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1, :query => "most recent day processed", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday - 1.day, :times => 10, :query => "outlier", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :times => 1, :query => "most recent day processed", :affiliate => "affiliate.gov")
        DailyQueryStat.create!(:day => Date.yesterday - 1.day, :times => 2, :query => "outlier", :affiliate => 'affiliate.gov')
        @ary = DailyQueryStat.reversed_backfilled_series_since_2009_for("outlier")
      end

      it "should return an array of query counts in reverse day order for a given query" do
        @ary[1].should == 12
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
        DailyQueryStat.create!(:day => @day, :times => 1, :query => "outlier", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
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
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 9, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 4, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "sparse term", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      let(:recent_date) { DailyQueryStat.most_recent_populated_date }

      it "should calculate popularity sums based on the start/end date, ignoring terms with a frequency of less than 4" do
        yday = DailyQueryStat.most_popular_terms(recent_date, recent_date, 1)
        yday.first.query.should == "recent day most popular"
        yday.first.times.should == 4
        twodaysago = DailyQueryStat.most_popular_terms(recent_date-1.day, recent_date, 2)
        twodaysago.first.query.should == "older most popular"
        twodaysago.first.times.should == 10
      end

      it "should use the num_results parameter to determine result set size" do
        DailyQueryStat.most_popular_terms(recent_date, recent_date, 1).size.should == 1
      end

      context "when data exists for more than the default affiliate" do
        before do
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "older most popular", :times => 10, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "recent day most popular", :times => 3, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "older most popular", :times => 2, :affiliate => "other_affiliate")
          DailyQueryStat.create!(:day => 11.days.ago.to_date, :query => "recent day most popular", :times => 5, :affiliate => "other_affiliate")
        end

        it "should use the affiliate parameter if set to scope the results" do
          yday = DailyQueryStat.most_popular_terms(recent_date, recent_date, 10, "other_affiliate")
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 5
          twodaysago = DailyQueryStat.most_popular_terms(recent_date-2.days, recent_date, 10, "other_affiliate")
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 12
        end
      end

      context "when a very small amount of affiliate data exists" do
        before do
          DailyQueryStat.create!(:day => Date.yesterday, :query => "sparse term", :times => 1, :affiliate => "tiny_affiliate")
        end

        it "should return those results for affiliates" do
          mrd=DailyQueryStat.most_recent_populated_date("tiny_affiliate")
          most_popular_terms = DailyQueryStat.most_popular_terms(mrd, mrd, 10, "tiny_affiliate")
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
          yday = DailyQueryStat.most_popular_terms(recent_date, recent_date)
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 4
          twodaysago = DailyQueryStat.most_popular_terms(recent_date - 2.days, recent_date)
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 10
        end

        it "should use the locale parameter if set to scope the results" do
          yday = DailyQueryStat.most_popular_terms(recent_date, recent_date, 10, Affiliate::USAGOV_AFFILIATE_NAME, 'es')
          yday.first.query.should == "recent day most popular"
          yday.first.times.should == 10
          twodaysago = DailyQueryStat.most_popular_terms(recent_date - 2.days, recent_date, 10, Affiliate::USAGOV_AFFILIATE_NAME, 'es')
          twodaysago.first.query.should == "older most popular"
          twodaysago.first.times.should == 24
        end
      end
    end

    context "when the table has no data for the time period specified" do
      it "should return an error string that no queries matched" do
        DailyQueryStat.most_popular_terms(Date.tomorrow, Date.tomorrow).should == "Not enough historic data to compute most popular"
      end
    end
  end

  describe "#most_popular_query_groups" do
    context "when the table has no query group data for the time period specified" do
      before do
        DailyQueryStat.delete_all
      end

      it "should return an error string that no queries matched" do
        DailyQueryStat.most_popular_query_groups(DailyQueryStat.most_recent_populated_date, 1).should == "Not enough historic data to compute most popular"
      end
    end

    context "when the table is populated with multiple affiliates and locales over multiple days" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 500, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 50, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 200, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 20, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query1", :times => 100, :affiliate => 'affiliate.gov')
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query2", :times => 10, :affiliate => 'affiliate.gov')
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "query1", :times => 100, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => 12.days.ago.to_date, :query => "query2", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query3", :times => 100, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Date.yesterday, :query => "query4", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        qg1 = QueryGroup.create!(:name=>"qg1")
        qg1.grouped_queries << GroupedQuery.create!(:query=>"query1")
        qg1.grouped_queries << GroupedQuery.create!(:query=>"query2")
        qg2 = QueryGroup.create!(:name=>"qg2")
        qg2.grouped_queries << GroupedQuery.create!(:query=>"query3")
        qg2.grouped_queries << GroupedQuery.create!(:query=>"query4")
      end

      it "should calculate popularity sums for the query groups based on the target date, affiliate, locale, and number of days parameter" do
        yday = DailyQueryStat.most_popular_query_groups(DailyQueryStat.most_recent_populated_date, 1)
        yday.first.query.should == "qg1"
        yday.first.times.should == 550
        yday.last.query.should == "qg2"
        yday.last.times.should == 110
      end

      it "should use the num_results parameter to determine result set size" do
        DailyQueryStat.most_popular_query_groups(DailyQueryStat.most_recent_populated_date, 1, 1).size.should == 1
      end
    end

  end

  describe "#most_recent_populated_date" do
    it "should return the most recent date entered into the table for the default affiliate and locale" do
      DailyQueryStat.should_receive(:maximum).with(:day, :conditions => ['affiliate = ?', Affiliate::USAGOV_AFFILIATE_NAME])
      DailyQueryStat.most_recent_populated_date
    end

    it "should return the most recent date for an affiliate if an affiliate is passed in" do
      DailyQueryStat.should_receive(:maximum).with(:day, :conditions => ['affiliate = ?', 'nps.gov'])
      DailyQueryStat.most_recent_populated_date('nps.gov')
    end

  end

  describe "#collect_query_group_named" do
    let(:start_date) do
      Date.yesterday.advance(:months => -1)
    end

    let(:before_start_date) do
      start_date.advance(:days => -1)
    end

    before do
      DailyQueryStat.delete_all

      DailyQueryStat.create!(:day => before_start_date, :query => "query1", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => before_start_date, :query => "query2", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => before_start_date, :query => "query1", :times => 10, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => before_start_date, :query => "query2", :times => 1, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => before_start_date, :query => "query1", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')
      DailyQueryStat.create!(:day => before_start_date, :query => "query2", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')

      DailyQueryStat.create!(:day => start_date, :query => "query1", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => start_date, :query => "query2", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => start_date, :query => "query1", :times => 10, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => start_date, :query => "query2", :times => 1, :affiliate => 'affiliate.gov')
      DailyQueryStat.create!(:day => start_date, :query => "query1", :times => 10, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')
      DailyQueryStat.create!(:day => start_date, :query => "query2", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es')

      qg = QueryGroup.create!(:name=>"my query group")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query1")
      qg.grouped_queries << GroupedQuery.create!(:query=>"query2")
    end

    it "should return an array of DailyQueryStats that sums the frequencies for all queries in query group, combining other affiliates and locales on or after start date" do
      results = DailyQueryStat.collect_query_group_named("my query group", start_date)
      results.size.should == 1
      results.first.day.should == start_date
      results.first.times.should == 33
    end

    context "when one of the queries has a single quote in it" do
      before do
        DailyQueryStat.create(:query => "jobs", :day => Date.yesterday, :times => 20, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'en')
        DailyQueryStat.create(:query => "job's", :day => Date.yesterday, :times => 25, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'en')
        query_group = QueryGroup.create!(:name => 'group2')
        query_group.grouped_queries << GroupedQuery.create!(:query => "jobs")
        query_group.grouped_queries << GroupedQuery.create!(:query => "job's")
      end

      it "should return results normally" do
        results = DailyQueryStat.collect_query_group_named("group2", start_date)
        results.size.should == 1
        results.first.day.should == Date.yesterday
        results.first.times.should == 45
      end
    end
  end

  describe "#collect_query" do
    let(:start_date) do
      Date.yesterday.advance(:months => -1)
    end

    it "should filter results using affiliate_name and query" do
      DailyQueryStat.should_receive(:generic_collection).with(['day >= ? AND query = ?', start_date, 'foo'])
      DailyQueryStat.collect_query('foo', start_date)
    end
  end

  describe "#collect_affiliate_query" do
    let(:start_date) do
      Date.yesterday.advance(:months => -1)
    end

    it "should filter results using affiliate_name and query" do
      DailyQueryStat.should_receive(:generic_collection).with(['day >= ? AND affiliate = ? AND query = ?', start_date, 'aff', 'foo'])
      DailyQueryStat.collect_affiliate_query('foo', 'aff', start_date)
    end
  end

  describe "#bulk_remove_solr_records_for_day(day)" do
    before do
      DailyQueryStat.delete_all
      @first = DailyQueryStat.create!(:day => "20110828", :query => "government", :times => 314)
      DailyQueryStat.create!(:day => "20110829", :query => "government", :times => 314)
      DailyQueryStat.create!(:day => "20110829", :query => "government loan", :times => 314)
      @last = DailyQueryStat.create!(:day => "20110830", :query => "government", :times => 314)
      DailyQueryStat.reindex
      Sunspot.commit
    end

    it "should remove records from index for specified day" do
      DailyQueryStat.bulk_remove_solr_records_for_day(Date.parse("20110829"))
      DailyQueryStat.search_for("government", Date.parse("20110828")).should == [@first.id, @last.id]
    end

  end

  describe "#reindex_day(day)" do
    before do
      ResqueSpec.reset!
    end

    it "should enqueue reindexing" do
      DailyQueryStat.reindex_day(Date.current)
      DailyQueryStat.should have_queued(Date.current)
    end
  end

  describe "#perform(day_string)" do
    it "should bulk remove the day's records from Solr and then index from DB all records for a given day" do
      DailyQueryStat.should_receive(:bulk_remove_solr_records_for_day).with daily_query_stats(:sample).day
      Sunspot.should_receive(:index!).with([daily_query_stats(:sample)])
      DailyQueryStat.perform(daily_query_stats(:sample).day.to_s)
    end
  end

end

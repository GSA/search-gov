require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "summary_tables rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/summary_tables"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:moving_queries" do

    describe "usasearch:moving_queries:populate" do
      before do
        @task_name = "usasearch:moving_queries:populate"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when daily_query_stats data is available over some date range" do
        before do
          DailyQueryStat.delete_all
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME) }
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => 'affiliate.gov') }
          Date.yesterday.upto(Date.tomorrow) { |day| DailyQueryStat.create!(:day => day, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => 'es') }
        end

        it "should calculate moving queries for each day in that range, ignoring affiliates and non-English locales" do
          MovingQuery.should_receive(:compute_for).with(Date.yesterday.to_s(:number))
          MovingQuery.should_receive(:compute_for).with(Date.today.to_s(:number))
          MovingQuery.should_receive(:compute_for).with(Date.tomorrow.to_s(:number))
          @rake[@task_name].invoke
        end
      end
    end

    describe "usasearch:moving_queries:compute" do
      before do
        @task_name = "usasearch:moving_queries:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when no target date is passed in" do
        it "should default to calculating yesterday's moving queries" do
          MovingQuery.should_receive(:compute_for).once.with(Date.yesterday.to_s(:number))
          @rake[@task_name].invoke
        end
      end

      context "when target date is passed in" do
        it "should calculate moving queries for that date" do
          MovingQuery.should_receive(:compute_for).once.with(Date.today.to_s(:number))
          @rake[@task_name].invoke(Date.today.to_s(:number))
        end
      end
    end

  end

  describe "usasearch:daily_popular_queries" do
    describe "usasearch:daily_popular_queries:calculate" do
      before do
        @task_name = "usasearch:daily_popular_queries:calculate"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when no parameters are passed" do
        before do
          @day = Date.yesterday
        end

        it "should calculate the daily popular queries and query groups for the previous day for each of the time frames, and create DailyPopularQuery records" do
          [1, 7, 30].each do |time_frame|
            DailyQueryStat.should_receive(:most_popular_terms).with(@day, time_frame, 1000).and_return [QueryCount.new("query", 100)]
             DailyPopularQuery.should_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(@day, nil, 'en', "query", false, time_frame).and_return DailyPopularQuery.new
            DailyQueryStat.should_receive(:most_popular_query_groups).with(@day, time_frame, 1000).and_return [QueryCount.new("query", 100)]
             DailyPopularQuery.should_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(@day, nil, 'en', "query", true, time_frame).and_return DailyPopularQuery.new
          end
          @rake[@task_name].invoke
        end
      end

      context "when a day is specified" do
        before do
          @day = Date.yesterday - 2.days
        end

        it "should calculate the daily popular queries and query groups for the date specified up to the previous day for each of the time frames, and create DailyPopularQuery records" do
          @day.upto(Date.yesterday) do |day|
            [1, 7, 30].each do |time_frame|
              DailyQueryStat.should_receive(:most_popular_terms).with(day, time_frame, 1000).and_return [QueryCount.new("query", 100)]
               DailyPopularQuery.should_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(day, nil, 'en', "query", false, time_frame).and_return DailyPopularQuery.new
              DailyQueryStat.should_receive(:most_popular_query_groups).with(day, time_frame, 1000).and_return [QueryCount.new("query", 100)]
               DailyPopularQuery.should_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(day, nil, 'en', "query", true, time_frame).and_return DailyPopularQuery.new
            end
          end
          @rake[@task_name].invoke(@day.to_s)
        end
      end

      context "when a start and end date are specified" do
        before do
          @start_date = Date.yesterday - 3.days
          @end_date = Date.yesterday - 1.days
        end

        it "should calculate the daily popular queries and query groups for the dates specified for each time frame, and create DailyPopularQuery records" do
          @start_date.upto(@end_date) do |day|
            [1, 7, 30].each do |time_frame|
              DailyQueryStat.should_receive(:most_popular_terms).with(day, time_frame, 1000).and_return "Insufficient data"
              DailyPopularQuery.should_not_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(day, nil, 'en', "query", false, time_frame).and_return DailyPopularQuery.new
              DailyQueryStat.should_receive(:most_popular_query_groups).with(day, time_frame, 1000).and_return "Insufficient data"
              DailyPopularQuery.should_not_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(day, nil, 'en', "query", true, time_frame).and_return DailyPopularQuery.new
            end
          end
          @rake[@task_name].invoke(@start_date.to_s, @end_date.to_s)
        end
      end


      context "when the most popular terms/groups are strings, not arrays" do
        before do
          @day = Date.yesterday
        end

        it "should calculate the daily popular queries and query groups for the previous day for each of the time frames, and create DailyPopularQuery records" do
          [1, 7, 30].each do |time_frame|
            DailyQueryStat.should_receive(:most_popular_terms).with(@day, time_frame, 1000).and_return "Insufficient data"
            DailyPopularQuery.should_not_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(@day, nil, 'en', "query", false, time_frame).and_return DailyPopularQuery.new
            DailyQueryStat.should_receive(:most_popular_query_groups).with(@day, time_frame, 1000).and_return "Insufficient data"
            DailyPopularQuery.should_not_receive(:find_or_create_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame).with(@day, nil, 'en', "query", true, time_frame).and_return DailyPopularQuery.new
          end
          @rake[@task_name].invoke
        end
      end
    end
  end

  describe "usasearch:monthly_popular_queries" do
    describe "usasearch:monthly_popular_queries:calculate" do
      before do
        @task_name = "usasearch:monthly_popular_queries:calculate"
        DailyQueryStat.create(:day => Date.yesterday, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create(:day => Date.yesterday.yesterday, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        query_group = QueryGroup.create(:name => 'Group1')
        query_group.grouped_queries << GroupedQuery.new(:query => "whatever")
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when no parameters are passed" do
        it "should calculate the popular queries/clicks for the month of the previous day" do
          DailyQueryStat.should_receive(:most_popular_terms_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return []
          DailyQueryStat.should_receive(:most_popular_groups_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return []
          Click.should_receive(:monthly_totals_by_module).with(Date.yesterday.year, Date.yesterday.month).and_return ActiveSupport::OrderedHash.new
          @rake[@task_name].invoke
        end

        it "should create monthly popular query records for the monthly total" do
          @rake[@task_name].invoke
          mpq = MonthlyPopularQuery.find_all_by_year_and_month_and_query(Date.yesterday.year, Date.yesterday.month, "whatever")
          mpq.should_not be_nil
          mpq.size.should == 1
          mpq.first.times.should == 20
        end

        it "should create monthly popular query groups for the monthly total" do
          @rake[@task_name].invoke
          mpgq = MonthlyPopularQuery.find_all_by_year_and_month_and_is_grouped(Date.yesterday.year, Date.yesterday.month, "Group1")
          mpgq.should_not be_nil
          mpgq.size.should == 1
          mpgq.first.times.should == 20
        end

        context "when a String is returned instead of a list of queries/counts" do
          it "should not attempt to generate any monthly popular queries" do
            DailyQueryStat.should_receive(:most_popular_terms_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return "Not enough historic data to compute most popular"
            DailyQueryStat.should_receive(:most_popular_groups_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return "Nothing"
            MonthlyPopularQuery.should_not_receive(:find_or_create_by_year_and_month_and_query_and_is_grouped)
            @rake[@task_name].invoke
          end
        end

        context "for clicks" do
          before do
            1.upto(100) do
              c = Click.create(:clicked_at => Time.now, :queried_at => Time.now, :url => 'http://something.com', :query => 'something', :results_source => 'TEST')
            end
          end

          it "should update the monthly total clicks" do
            @rake[@task_name].invoke
            click_totals = MonthlyClickTotal.find_all_by_year_and_month(Date.yesterday.year, Date.yesterday.month)
            click_totals.should_not be_nil
            click_totals.size.should == 1
            click_totals.first.source.should == "TEST"
            click_totals.first.total.should == 100
          end
        end
      end

      context "when a date parameter is passed" do
        it "should calcukate the popular queries for the month associated with the date specified" do
          DailyQueryStat.should_receive(:most_popular_terms_for_year_month).with(2011, 2, 1000).and_return []
          DailyQueryStat.should_receive(:most_popular_groups_for_year_month).with(2011, 2, 1000).and_return []
          Click.should_receive(:monthly_totals_by_module).with(2011, 2).and_return ActiveSupport::OrderedHash.new
          @rake[@task_name].invoke('2011-02-11')
        end
      end
    end
  end
end
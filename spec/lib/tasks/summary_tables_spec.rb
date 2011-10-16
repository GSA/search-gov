require 'spec/spec_helper'

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
          MovingQuery.should_receive(:compute_for).with(Date.current.to_s(:number))
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
          MovingQuery.should_receive(:compute_for).once.with(Date.current.to_s(:number))
          @rake[@task_name].invoke(Date.current.to_s(:number))
        end
      end
    end

  end

  describe "usasearch:daily_popular_query_groups" do
    describe "usasearch:daily_popular_query_groups:calculate" do
      let(:task_name) { "usasearch:daily_popular_query_groups:calculate"}

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      context "when no parameters are passed" do
        it "should call #calculate with the previous day for each of the time frames" do
          [1, 7, 30].each do |time_frame|
            DailyPopularQueryGroup.should_receive(:calculate).with(Date.yesterday, time_frame)
          end
          @rake[task_name].invoke
        end
      end

      context "when a single day is specified" do
        let(:start_day) { Date.yesterday - 2.days }

        it "should call #calculate with the date specified up to the previous day for each of the time frames" do
          start_day.upto(Date.yesterday) do |day|
            [1, 7, 30].each do |time_frame|
              DailyPopularQueryGroup.should_receive(:calculate).with(day, time_frame)
            end
          end
          @rake[task_name].invoke(start_day.to_s)
        end
      end

      context "when both a start day and end day are specified" do
        let(:start_day) { Date.yesterday - 4.days }
        let(:end_day) { Date.yesterday - 2.days }

        it "should call #calculate with the start/end dates specified for each of the time frames" do
          start_day.upto(end_day) do |day|
            [1, 7, 30].each do |time_frame|
              DailyPopularQueryGroup.should_receive(:calculate).with(day, time_frame)
            end
          end
          @rake[task_name].invoke(start_day.to_s, end_day.to_s)
        end
      end

    end
  end

  describe "usasearch:monthly_popular_queries" do
    describe "usasearch:monthly_popular_queries:calculate" do
      before do
        @task_name = "usasearch:monthly_popular_queries:calculate"
        @first_stat_date = Date.yesterday
        DailyQueryStat.create(:day => @first_stat_date, :times => 10, :query => "whatever", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        query_group = QueryGroup.create(:name => 'Group1')
        query_group.grouped_queries << GroupedQuery.new(:query => "whatever")
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when no parameters are passed" do
        it "should create monthly popular query records for the monthly total" do
          @rake[@task_name].invoke
          mpq = MonthlyPopularQuery.find_all_by_year_and_month_and_query(@first_stat_date.year, @first_stat_date.month, "whatever")
          mpq.should_not be_nil
          mpq.size.should == 1
          mpq.first.times.should == 10
        end

        it "should create monthly popular query groups for the monthly total" do
          @rake[@task_name].invoke
          mpgq = MonthlyPopularQuery.find_all_by_year_and_month_and_is_grouped(@first_stat_date.year, @first_stat_date.month, "Group1")
          mpgq.should_not be_nil
          mpgq.size.should == 1
          mpgq.first.times.should == 10
        end

        context "when a String is returned instead of a list of queries/counts" do
          before do
            MonthlyPopularQuery.delete_all
          end

          it "should not attempt to generate any monthly popular queries" do
            DailyQueryStat.should_receive(:most_popular_terms_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return "Not enough historic data to compute most popular"
            DailyQueryStat.should_receive(:most_popular_groups_for_year_month).with(Date.yesterday.year, Date.yesterday.month, 1000).and_return "Nothing"
            @rake[@task_name].invoke
            MonthlyPopularQuery.count.should be_zero
          end
        end
      end

      context "when a date parameter is passed" do
        it "should calculate the popular queries for the month associated with the date specified" do
          DailyQueryStat.should_receive(:most_popular_terms_for_year_month).with(2011, 2, 1000).and_return []
          DailyQueryStat.should_receive(:most_popular_groups_for_year_month).with(2011, 2, 1000).and_return []
          @rake[@task_name].invoke('2011-02-11')
        end
      end
    end
  end
end

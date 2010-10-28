require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "summary_tables rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/summary_tables"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_query_stats" do

    describe "usasearch:daily_query_stats:index_most_recent_day_stats_in_solr" do
      before do
        @task_name = "usasearch:daily_query_stats:index_most_recent_day_stats_in_solr"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when daily_query_stats data is available over some date range" do
        before do
          DailyQueryStat.delete_all
          DailyQueryStat.create!(:day => Date.yesterday, :times => 10, :query => "ignore me", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
          @first = DailyQueryStat.create!(:day => Date.today, :times => 20, :query => "index me", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
          @second = DailyQueryStat.create!(:day => Date.today, :times => 20, :query => "index me too", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        end

        it "should call Sunspot.index on the most-recently-added DailyQueryStat models" do
          Sunspot.should_receive(:index).with([@first, @second])
          @rake[@task_name].invoke
        end
      end
    end

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
end
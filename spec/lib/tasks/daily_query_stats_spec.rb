require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "daily_query_stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/daily_query_stats"
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

end
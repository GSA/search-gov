require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Daily Usage Stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/daily_usage_stats"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:update_webtrends_stats" do
    before do
      @task_name = "usasearch:update_webtrends_stats"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should update the webtrends stats for yesterday" do
      DailyUsageStat.should_receive(:update_webtrends_stats_for).with(Date.yesterday)
      @rake[@task_name].invoke
    end

  end

  describe "#compute_daily_contextual_query_total" do
    before do
      @task_name = "usasearch:compute_daily_contextual_query_total"
      DailyContextualQueryTotal.delete_all
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should use the date provided as a parameter" do
      @rake[@task_name].invoke('2010-09-01')
      DailyContextualQueryTotal.find_by_day(Date.parse('2010-09-01')).should_not be_nil
    end

    it "should default to yesterday if no day is provided as a parameter" do
      @rake[@task_name].invoke
      DailyContextualQueryTotal.find_by_day(Date.yesterday).should_not be_nil
    end

    context "when a record exists for the date being totaled" do
      before do
        DailyContextualQueryTotal.create(:day => Date.yesterday, :total => 100)
      end

      it "should delete the existing record and create a new one with the new total" do
        @rake[@task_name].invoke
        DailyContextualQueryTotal.find_by_day(Date.yesterday).total.should == 0
      end
    end
  end
end

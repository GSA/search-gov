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

    context "when no start_date or end_date is specified" do
      it "should update the webtrends stats for the past 3 days" do
        (Date.yesterday - 2.days).upto(Date.yesterday) do |date|
          DailyUsageStat.should_receive(:update_webtrends_stats_for).with(date)
        end
        @rake[@task_name].invoke
      end
    end

    context "when start_date and end_date are specified" do
      it "should update the webtrends stats for the specified days" do
        DailyUsageStat.should_receive(:update_webtrends_stats_for).with(Date.parse("20110501"))
        DailyUsageStat.should_receive(:update_webtrends_stats_for).with(Date.parse("20110502"))
        @rake[@task_name].invoke("20110501","20110502")
      end
    end

  end

end

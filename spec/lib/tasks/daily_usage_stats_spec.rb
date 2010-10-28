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

end

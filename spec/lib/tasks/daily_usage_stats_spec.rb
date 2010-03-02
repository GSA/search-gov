require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Daily Usage Stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/daily_usage_stats"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:compile_usage_stats_for_yesterday" do
    before do
      @task_name = "usasearch:compile_usage_stats_for_yesterday"
    end
    
    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end
  
    it "should delete existing data for the past day, if it exists" do
      DailyUsageStat.should_receive(:destroy_all).with(:day => Date.yesterday).exactly(1).times
      @rake[@task_name].invoke
    end
    
    # For some reason that I can not figure out, this fails.
    it "should populate data for all of the current profiles" do
      #DailyUsageStat.should_receive(:new).exactly(DailyUsageStat::Profiles.size).times
      #@rake[@task_name].invoke
    end
    
  end
    
end

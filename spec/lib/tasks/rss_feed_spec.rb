require 'spec/spec_helper'

describe "Affiliate RSS feed rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/rss_feed"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:rss_feed:refresh_all" do
    before do
      @task_name = "usasearch:rss_feed:refresh_all"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should refresh all affiliate RSS feeds" do
      RssFeed.should_receive(:refresh_all).once
      @rake[@task_name].invoke
    end
  end

end
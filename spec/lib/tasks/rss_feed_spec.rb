require 'spec_helper'

describe "Affiliate RSS feed rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/rss_feed')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:rss_feed:refresh_non_managed_feeds" do
    let(:task_name) { 'usasearch:rss_feed:refresh_non_managed_feeds' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should refresh non managed RSS feeds" do
      RssFeed.should_receive(:refresh_non_managed_feeds)
      @rake[task_name].invoke
    end
  end

  describe "usasearch:rss_feed:refresh_managed_feeds" do
    let(:task_name) { 'usasearch:rss_feed:refresh_managed_feeds' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should refresh managed affiliate RSS feeds" do
      RssFeed.should_receive(:refresh_managed_feeds)
      @rake[task_name].invoke
    end

    context "with freshen_managed_feeds and max_news_items_count" do
      it "should refresh managed affiliate RSS feeds" do
        RssFeed.should_receive(:refresh_managed_feeds).with(2000)
        @rake[task_name].invoke('2000')
      end
    end
  end
end

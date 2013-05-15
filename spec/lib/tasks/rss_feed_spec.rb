require 'spec_helper'

describe 'RSS feed rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/rss_feed')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:rss_feed:refresh_affiliate_feeds' do
    let(:task_name) { 'usasearch:rss_feed:refresh_affiliate_feeds' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should refresh affiliate RSS feeds' do
      RssFeedUrl.should_receive(:refresh_affiliate_feeds)
      @rake[task_name].invoke
    end
  end

  describe 'usasearch:rss_feed:refresh_youtube_feeds' do
    let(:task_name) { 'usasearch:rss_feed:refresh_youtube_feeds' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should refresh youtube RSS feeds' do
      ContinuousWorker.stub(:start).and_yield
      YoutubeData.should_receive :refresh_feeds
      @rake[task_name].invoke
    end
  end
end

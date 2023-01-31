require 'spec_helper'

describe 'RSS feed urls rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/rss_feed_urls')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:rss_feed_urls:enqueue_destroy_all_inactive' do
    let(:task_name) { 'usasearch:rss_feed_urls:enqueue_destroy_all_inactive' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should enqueue destroy all inactive' do
      expect(RssFeedUrl).to receive(:enqueue_destroy_all_inactive)
      @rake[task_name].invoke
    end
  end

  describe 'usasearch:rss_feed_urls:enqueue_destroy_all_news_items_with_404' do
    let(:task_name) { 'usasearch:rss_feed_urls:enqueue_destroy_all_news_items_with_404' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should enqueue destroy all news items with 404' do
      expect(RssFeedUrl).to receive(:enqueue_destroy_all_news_items_with_404)
      @rake[task_name].invoke
    end
  end
end

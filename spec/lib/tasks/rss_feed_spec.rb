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
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should refresh affiliate RSS feeds' do
      expect(RssFeedUrl).to receive(:refresh_affiliate_feeds)
      @rake[task_name].invoke
    end
  end
end

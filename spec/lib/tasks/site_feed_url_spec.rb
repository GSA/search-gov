require 'spec_helper'

describe 'RSS site feed URL rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/site_feed_url')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:site_feed_url:refresh_all' do
    let(:task_name) { 'usasearch:site_feed_url:refresh_all' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should refresh all RSS site feed URL feeds' do
      expect(SiteFeedUrl).to receive(:refresh_all)
      @rake[task_name].invoke
    end
  end
end
require 'spec_helper'

describe 'YouTube rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/youtube')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:youtube:refresh' do
    let(:task_name) { 'usasearch:youtube:refresh' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should run YoutubeData.refresh' do
      expect(YoutubeData).to receive :refresh
      @rake[task_name].invoke
    end
  end
end

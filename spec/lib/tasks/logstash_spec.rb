require 'spec_helper'

describe 'Logstash rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/logstash')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:logstash:dedupe' do
    let(:task_name) { 'usasearch:logstash:dedupe' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'enqueues a dedupe job per day' do
      expect(Resque).to receive(:enqueue_with_priority).with(:low, LogstashDeduper, '2015.08.24')
      expect(Resque).to receive(:enqueue_with_priority).with(:low, LogstashDeduper, '2015.08.25')
      expect(Resque).to receive(:enqueue_with_priority).with(:low, LogstashDeduper, '2015.08.26')
      @rake[task_name].invoke('2015-08-24', '2015-08-26')
    end
  end
end

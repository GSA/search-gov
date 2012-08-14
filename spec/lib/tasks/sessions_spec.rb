require 'spec_helper'

describe "Sessions rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/sessions')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sessions" do
    describe "usasearch:sessions:prune" do
      let(:task_name) { 'usasearch:sessions:prune' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      it "should delete sessions more than a week old" do
        Session.should_receive(:delete_all).with(["created_at < ?", 7.days.ago.beginning_of_day.to_s(:db)])
        @rake[task_name].invoke
      end
    end
  end
end

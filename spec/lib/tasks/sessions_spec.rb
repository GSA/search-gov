require 'spec_helper'

describe "Sessions rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/sessions.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sessions" do
    describe "usasearch:sessions:prune" do
      before do
        @task_name = "usasearch:sessions:prune"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should delete sessions more than a week old" do
        Session.should_receive(:delete_all).with(["created_at < ?", 7.days.ago.beginning_of_day.to_s(:db)])
        @rake[@task_name].invoke
      end
    end
  end
end

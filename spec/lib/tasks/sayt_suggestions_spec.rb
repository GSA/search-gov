require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "SAYT suggestions rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/sayt_suggestions"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sayt_suggestions" do

    describe "usasearch:sayt_suggestions:compute" do
      before do
        @task_name = "usasearch:sayt_suggestions:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when target day is specified" do
        it "should populate sayt_suggestions for that given day" do
          day = Date.today.to_s(:number).to_i
          SaytSuggestion.should_receive(:populate_for).with(day)
          @rake[@task_name].invoke(day)
        end
      end

      context "when target day is not specified" do
        it "should default to yesterday" do
          day = Date.yesterday.to_s(:number).to_i
          SaytSuggestion.should_receive(:populate_for).with(day)
          @rake[@task_name].invoke(day)
        end
      end
    end
  end
end
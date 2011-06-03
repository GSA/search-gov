require 'spec/spec_helper'

describe "query_log rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/query_log"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:query_log" do

    describe "usasearch:query_log:transform_to_hive_queries_format" do
      before do
        @task_name = "usasearch:query_log:transform_to_hive_queries_format"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not passed a log file parameter" do
        it "should print out an error message" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when passed a log file parameter" do
        it "should attempt to process the log file" do
          filename = "/path/to/file.log"
          LogFile.should_receive(:transform_to_hive_queries_format).with(filename)
          @rake[@task_name].invoke(filename)
        end
      end
    end

  end
end
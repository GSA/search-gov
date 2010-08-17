require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Related Search rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/related_searches"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:related_searches:load_related_queries" do
    before do
      @task_name = "usasearch:related_searches:load_related_queries"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    context "when not given a JSON file" do
      it "should print out an error message" do
        RAILS_DEFAULT_LOGGER.should_receive(:error)
        @rake[@task_name].invoke
      end
    end

    context "when given a JSON file" do
      it "should process the file" do
        RelatedQuery.should_receive(:load_json).with("/some/file").and_return true
        @rake[@task_name].invoke("/some/file")
      end
    end
  end
  
  describe "usasearch:related_searches:load_processed_queries" do
    before do
      @task_name = "usasearch:related_searches:load_processed_queries"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    context "when not given a CSV file" do
      it "should print out an error message" do
        RAILS_DEFAULT_LOGGER.should_receive(:error)
        @rake[@task_name].invoke
      end
    end

    context "when given a CSV file" do
      it "should process the file" do
        ProcessedQuery.should_receive(:load_csv).with("/some/file").and_return true
        @rake[@task_name].invoke("/some/file")
      end
    end
  end
end
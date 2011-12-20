require 'spec/spec_helper'

describe "Indexed document rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/indexed_document"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:indexed_document:refresh_all" do
    before do
      @task_name = "usasearch:indexed_document:refresh_all"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should refresh/index all affiliate indexed documents" do
      IndexedDocument.should_receive(:refresh_all).once
      @rake[@task_name].invoke
    end
  end

  describe "usasearch:indexed_document:bulk_load_urls" do
    before do
      @task_name = "usasearch:indexed_document:bulk_load_urls"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    context "when not given a data file" do
      it "should print out an error message" do
        Rails.logger.should_receive(:error)
        @rake[@task_name].invoke
      end
    end

    context "when given a data file" do
      it "should process the tab-delimited file of affiliate IDs and urls" do
        IndexedDocument.should_receive(:bulk_load_urls).with("/some/file")
        @rake[@task_name].invoke("/some/file")
      end
    end

  end

end
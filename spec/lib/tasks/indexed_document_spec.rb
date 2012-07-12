require 'spec/spec_helper'

describe "Indexed document rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/indexed_document.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:indexed_document:refresh" do
    before do
      @task_name = "usasearch:indexed_document:refresh"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    context "when the extent argument is passed in" do
      it "should fetch/index affiliate indexed documents based on the argument passed in" do
        IndexedDocument.should_receive(:refresh).once.with("not_ok")
        @rake[@task_name].invoke('not_ok')
      end
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
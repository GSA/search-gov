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

  describe "usasearch:indexed_document:index_unindexed" do
    before do
      @task_name = "usasearch:indexed_document:index_unindexed"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should index all unindexed affiliate documents" do
      IndexedDocument.should_receive(:index_unindexed).once
      @rake[@task_name].invoke
    end
  end

end
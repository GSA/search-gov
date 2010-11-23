require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "USA.gov rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/usa_gov"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:crawl_usa_gov" do
    before do
      @task_name = "usasearch:crawl_usa_gov"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should initiate the crawling/scraping of USA.gov" do
      SitePage.should_receive(:crawl_usa_gov).once
      @rake[@task_name].invoke
    end

  end
end
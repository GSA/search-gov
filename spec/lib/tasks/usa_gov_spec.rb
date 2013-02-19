require 'spec_helper'

describe "USA.gov rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/usa_gov')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:crawl_usa_gov" do
    let(:task_name) { 'usasearch:crawl_usa_gov' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should initiate the crawling/scraping of USA.gov" do
      SitePage.should_receive(:crawl_usa_gov).once
      @rake[task_name].invoke
    end
  end

  describe "usasearch:crawl_answers_usa_gov" do
    let(:task_name) { 'usasearch:crawl_answers_usa_gov' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should initiate the crawling/scraping of USA.gov" do
      SitePage.should_receive(:crawl_answers_usa_gov).once
      @rake[task_name].invoke
    end
  end

end

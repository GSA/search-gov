require 'spec/spec_helper'

describe "Bitly Rake Tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/bitly"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:bitly:compute_popular_urls" do
    before do
      @task_name = "usasearch:bitly:compute_popular_urls"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should compute popular urls for yesterday if no date is passed as a parameter" do
      AgencyPopularUrl.should_receive(:compute_for_date).with(Date.yesterday).and_return true
      @rake[@task_name].invoke
    end
    
    it "should compute popular urls for the date specified" do
      AgencyPopularUrl.should_receive(:compute_for_date).with(Date.parse('2011-07-01')).and_return true
      @rake[@task_name].invoke("2011-07-01")
    end
  end
end
require 'spec/spec_helper'

describe "Sitemap rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/sitemap.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sitemap:refresh" do
    before do
      @task_name = "usasearch:sitemap:refresh"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should fetch/index URLs from all affiliate sitemaps" do
      Sitemap.should_receive(:refresh)
      @rake[@task_name].invoke
    end
  end

end
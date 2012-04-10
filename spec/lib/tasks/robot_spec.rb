require 'spec/spec_helper'

describe "Robot rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/robot"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:robot:populate" do
    before do
      @task_name = "usasearch:robot:populate"
    end

    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end

    it "should populate/delete/manage robots from indexed_domains entries" do
      Robot.should_receive(:populate_from_indexed_domains)
      @rake[@task_name].invoke
    end
  end

end
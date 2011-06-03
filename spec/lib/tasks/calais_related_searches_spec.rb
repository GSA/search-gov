require 'spec/spec_helper'

describe "Calais related searches rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/calais_related_searches"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:calais_related_searches" do

    describe "usasearch:calais_related_searches:compute" do
      before do
        @task_name = "usasearch:calais_related_searches:compute"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should create/update related searches based on recent popular search terms" do
        CalaisRelatedSearch.should_receive(:populate_with_new_popular_terms)
        @rake[@task_name].invoke
      end
    end

    describe "usasearch:calais_related_searches:refresh" do
      before do
        @task_name = "usasearch:calais_related_searches:refresh"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should update related terms of oldest existing entries" do
        redis = CalaisRelatedSearch.send(:class_variable_get,:@@redis)
        redis.stub!(:incr).and_return(1)
        CalaisRelatedSearch.should_receive(:refresh_stalest_entries)
        @rake[@task_name].invoke
      end
    end

    describe "usasearch:calais_related_searches:prune_dead_ends" do
      before do
        @task_name = "usasearch:calais_related_searches:prune_dead_ends"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should prune calais_related_searches that yield no search results" do
        CalaisRelatedSearch.should_receive(:prune_dead_ends)
        @rake[@task_name].invoke
      end
    end

  end
end
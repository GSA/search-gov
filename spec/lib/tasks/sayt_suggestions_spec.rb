require 'spec_helper'

describe "SAYT suggestions rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/sayt_suggestions')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sayt_suggestions" do

    describe "usasearch:sayt_suggestions:compute" do
      let(:task_name) { 'usasearch:sayt_suggestions:compute' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      context "when target day is specified" do
        it "should populate sayt_suggestions for that given day" do
          day = Date.current.to_s(:number).to_i
          expect(SaytSuggestion).to receive(:populate_for).with(day, 1000)
          @rake[task_name].invoke(day)
        end
      end

      context "when target day is not specified" do
        it "should default to yesterday" do
          day = Date.yesterday.to_s(:number).to_i
          expect(SaytSuggestion).to receive(:populate_for).with(day, 1000)
          @rake[task_name].invoke
        end
      end

      context "when limit is specified" do
        it "should pass that along to #populate_for" do
          day = Date.current.to_s(:number).to_i
          limit = "20"
          expect(SaytSuggestion).to receive(:populate_for).with(day, limit.to_i)
          @rake[task_name].invoke(day, limit)
        end
      end

      context "when limit is not specified" do
        it "should pass 1000 to #populate_for" do
          day = Date.current.to_s(:number).to_i
          expect(SaytSuggestion).to receive(:populate_for).with(day, 1000)
          @rake[task_name].invoke(day)
        end
      end
    end

    describe "usasearch:sayt_suggestions:expire" do
      let(:task_name) { 'usasearch:sayt_suggestions:expire' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      context "when days back is specified" do
        it "should expire sayt_suggestions that have not been updated for that many days" do
          days_back = "7"
          expect(SaytSuggestion).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke(days_back)
        end
      end

      context "when days back is not specified" do
        it "should expire sayt_suggestions that have not been updated for 30 days" do
          days_back = "30"
          expect(SaytSuggestion).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke
        end
      end
    end
  end
end

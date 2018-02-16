require 'spec_helper'

describe "SaytFilters-related rake tasks" do
  fixtures :sayt_filters
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/sayt_filters')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:sayt_filters:filtered_popular_terms" do
    let(:task_name) { 'usasearch:sayt_filters:filtered_popular_terms' }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include("environment")
    end

    context "when there is info to email" do
      before do
        allow(RtuQueryStat).to receive(:top_n_overall_human_searches).with(1.week.ago.to_date, 5000).and_return [['filter me',1000]]
      end

      it "should call the Emailer's filtered_popular_terms_report method" do
        emailer = double(Emailer)
        expect(Emailer).to receive(:filtered_popular_terms_report).with(["filter me"]).and_return emailer
        expect(emailer).to receive(:deliver_now)
        @rake[task_name].invoke
      end
    end

    context "when there is no info to email" do
      before do
        allow(RtuQueryStat).to receive(:top_n_overall_human_searches).with(1.week.ago.to_date, 5000).and_return []
      end

      it "should handle the nil email" do
        expect(Emailer).not_to receive(:filtered_popular_terms_report)
        @rake[task_name].invoke
      end
    end
  end
end

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
      @rake[task_name].prerequisites.should include("environment")
    end

    context "when there is info to email" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "filter me",
                               :times => 314, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should call the Emailer's filtered_popular_terms_report method" do
        emailer = mock(Emailer)
        Emailer.should_receive(:filtered_popular_terms_report).with(["filter me"]).and_return emailer
        emailer.should_receive(:deliver)
        @rake[task_name].invoke
      end
    end

    context "when there is no info to email" do
      before do
        DailyQueryStat.delete_all
      end

      it "should handle the nil email" do
        Emailer.should_not_receive(:filtered_popular_terms_report)
        @rake[task_name].invoke
      end
    end
  end
end
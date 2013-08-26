require 'spec_helper'

describe "daily_query_stats rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/daily_query_stats')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_query_stats" do
    describe "usasearch:daily_query_stats:reindex_day" do
      let(:task_name) { "usasearch:daily_query_stats:reindex_day" }
      before { @rake[task_name].reenable }

      it "should call #reindex for the given day" do
        DailyQueryStat.should_receive(:reindex_day).with("2011-08-13")
        @rake[task_name].invoke("2011-08-13")
      end

      context "when no date is given" do
        it "should complain" do
          Rails.logger.should_receive(:error)
          @rake[task_name].invoke
        end
      end
    end

    describe "usasearch:daily_query_stats:prune_before" do
      let(:task_name) { "usasearch:daily_query_stats:prune_before" }
      before { @rake[task_name].reenable }

      it "should call #prune_before for X months ago" do
        months_back = '13'
        DailyQueryStat.should_receive(:prune_before).with(months_back.to_i.months.ago.beginning_of_month.beginning_of_day)
        @rake[task_name].invoke("13")
      end
    end

  end

end

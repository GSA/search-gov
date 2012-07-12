require 'spec/spec_helper'

describe "daily_query_stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/daily_query_stats.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_query_stats" do

    describe "usasearch:daily_query_stats:reindex_day" do
      let(:task_name) { "usasearch:daily_query_stats:reindex_day" }

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

  end

end
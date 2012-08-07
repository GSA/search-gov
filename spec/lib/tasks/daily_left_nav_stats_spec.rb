require 'spec_helper'

describe "daily_left_nav_stats rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/daily_left_nav_stats.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_left_nav_stat" do

    describe "usasearch:daily_left_nav_stat:bulk_load" do
      let(:task_name) { "usasearch:daily_left_nav_stat:bulk_load" }

      it "should call #bulk_load with the data file for the given day" do
        DailyLeftNavStat.should_receive(:bulk_load).with("/data/file.txt","2011-08-13")
        @rake[task_name].invoke("/data/file.txt","2011-08-13")
      end

      context "when date or file is missing" do
        it "should complain" do
          Rails.logger.should_receive(:error)
          @rake[task_name].invoke
        end
      end
    end

  end

end

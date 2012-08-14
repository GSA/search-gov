require 'spec_helper'

describe "daily_left_nav_stats rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/daily_left_nav_stats')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:daily_left_nav_stat" do
    describe "usasearch:daily_left_nav_stat:bulk_load" do
      let(:task_name) { "usasearch:daily_left_nav_stat:bulk_load" }
      before { @rake[task_name].reenable }

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

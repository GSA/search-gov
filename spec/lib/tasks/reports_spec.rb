require 'spec/spec_helper'

describe "Report generation rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/reports"
    Rake::Task.define_task(:environment)
    @emailer = mock(Emailer)
    @emailer.stub!(:deliver).and_return true
  end

  describe "usasearch:reports" do
    describe "usasearch:reports:generate_top_queries_from_file" do
      before do
        @task_name = "usasearch:reports:generate_top_queries_from_file"
        AWS::S3::Base.stub!(:establish_connection).and_return true
        AWS::S3::Bucket.stub!(:find).and_return true
        AWS::S3::S3Object.stub!(:store).and_return true
        @input_file_name = ::Rails.root.to_s + "/generate_top_queries_from_file_input_file.txt"
        File.open(@input_file_name, 'w+') do |file|
          file.puts(%w{affiliate1 query1 11}.join("\001"))
          file.puts(%w{affiliate1 query2 10}.join("\001"))
          file.puts(%w{affiliate2 query2 22}.join("\001"))
        end
        @affiliate1_csv_output = ["Query,Count","query1,11","query2,10",""].join("\n")
        @affiliate2_csv_output = ["Query,Count","query2,22",""].join("\n")
      end

      context "when file_name or period or max entries for each group is not set" do
        it "should log an error" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it "should establish an AWS S3 connection" do
        AWS::S3::Base.should_receive(:establish_connection!).once
        @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
      end

      it "should check to make sure the bucket for search reports exists" do
        AWS::S3::Bucket.should_receive(:find).with(AWS_BUCKET_NAME).once
        @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
      end

      context "when the reports bucket does not exist" do
        before do
          AWS::S3::Bucket.stub!(:find).and_raise "Can't find bucket"
          AWS::S3::Bucket.stub!(:create).and_return true
        end

        it "should create the bucket if it doesn't exist" do
          AWS::S3::Bucket.should_receive(:create).with(AWS_BUCKET_NAME).once
          @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
        end
      end

      it "should output the CSV of the query and counts for each affiliate to a file in the AWS bucket" do
        AWS::S3::S3Object.should_receive(:store).with(anything(), @affiliate1_csv_output, AWS_BUCKET_NAME).once.ordered
        AWS::S3::S3Object.should_receive(:store).with(anything(), @affiliate2_csv_output, AWS_BUCKET_NAME).once.ordered
        @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
      end

      context "when period is set to monthly" do
        it "should set the report filenames using YYMM" do
          yymm = Date.yesterday.strftime('%Y%m')
          AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
          AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
          @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
        end
      end

      context "when period is set to daily" do
        it "should set the report filenames using YYMMDD" do
          yymmdd = Date.yesterday.strftime('%Y%m%d')
          AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
          AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
          @rake[@task_name].invoke(@input_file_name, "daily", "1000")
        end
      end

      context "when a group has more than max entries per group" do
        it "should truncate the output" do
          truncated_affiliate1_csv_output = ["Query,Count","query1,11",""].join("\n")
          AWS::S3::S3Object.should_receive(:store).with(anything(), truncated_affiliate1_csv_output, AWS_BUCKET_NAME).once
          @rake[@task_name].invoke(@input_file_name, "daily", "1")
        end
      end

      context "when a date is specified" do
        context "for a monthly report" do
          it "should set the report filename to the month specfieid" do
            yymm = Date.parse('2011-02-02').strftime('%Y%m')
            AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
            AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
            @rake[@task_name].invoke(@input_file_name, "monthly", "1000", '2011-02-02')
          end
        end

        context "for a daily report" do
          it "should set the report filename to the date specified" do
            yymmdd = Date.parse('2011-02-01').strftime('%Y%m%d')
            AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
            AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
            @rake[@task_name].invoke(@input_file_name, "daily", "1000", '2011-02-01')
          end
        end

        after do
          File.delete(@input_file_name)
        end
      end
    end

    describe "usasearch:reports:reprocess_dates" do
      before do
        @task_name = "usasearch:reports:reprocess_dates"
      end
      
      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end
      
      it "should output the first and last day of the previous month" do
        end_of_last_month = Date.current.beginning_of_month - 1.days
        expected_output = "#{end_of_last_month.beginning_of_month.strftime('%Y%m%d')} #{end_of_last_month.strftime('%Y%m%d')}"
        Kernel.should_receive(:puts).with(expected_output)
        @rake[@task_name].invoke
      end
    end
    
    describe "usasearch:reports:weekly_report" do
      before do
        @task_name = "usasearch:reports:weekly_report"
        @start_date = Date.yesterday.beginning_of_week
        @zip_filename = "/tmp/weekly_report_#{@start_date.strftime('%Y-%m-%d')}.zip"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end
    
      context "when running the task" do
        it "should create a zip file in a temporary location, add a bunch of files to it, email it, and delete it after it's been sent" do
          Emailer.should_receive(:monthly_report).with(@zip_filename, @start_date.beginning_of_week, "Weekly Report data attached").and_return @emailer
          File.should_receive(:delete).with(@zip_filename).and_return true
          @rake[@task_name].invoke
          Zip::ZipFile.open(@zip_filename) do |zip_file|
            zip_file.get_entry('affiliate_report.txt')
          end
        end
      end
    end
    
    describe "usasearch:reports:monthly_report" do
      before do
        @task_name = "usasearch:reports:monthly_report"
        @start_date = Date.current.beginning_of_month - 1.day
        @zip_filename = "/tmp/monthly_report_#{@start_date.strftime('%Y-%m')}.zip"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when running the task" do
        it "should create a zip file in a temporary location, add a bunch of files to it, email it, and delete it after it's been sent" do
          Emailer.should_receive(:monthly_report).with(@zip_filename, @start_date.beginning_of_month, "Monthly Report data attached").and_return @emailer
          File.should_receive(:delete).with(@zip_filename).and_return true
          @rake[@task_name].invoke
          Zip::ZipFile.open(@zip_filename) do |zip_file|
            zip_file.get_entry('top_monthly_query_groups_en.txt')
            zip_file.get_entry('top_monthly_query_groups_es.txt')
            zip_file.get_entry('top_monthly_query_groups_affiliates.txt')
            zip_file.get_entry('top_monthly_queries_en.txt')
            zip_file.get_entry('top_monthly_queries_es.txt')
            zip_file.get_entry('top_monthly_queries_affiliates.txt')
            zip_file.get_entry('top_affiliates.txt')
            zip_file.get_entry('affiliate_queries_by_month.txt')
            zip_file.get_entry('click_totals.txt')
            zip_file.get_entry('affiliate_report.txt')
            zip_file.get_entry('total_queries_by_profile.txt')
          end
        end
      end
    end
  end
end
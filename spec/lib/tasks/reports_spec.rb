require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "Report generation rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/reports"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:reports" do
    describe "usasearch:reports:generate_top_queries_from_file" do
      before do
        @task_name = "usasearch:reports:generate_top_queries_from_file"
        AWS::S3::Base.stub!(:establish_connection).and_return true
        AWS::S3::Bucket.stub!(:find).and_return true
        AWS::S3::S3Object.stub!(:store).and_return true
        @input_file_name = "/tmp/generate_top_queries_from_file_input_file.txt"
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
          RAILS_DEFAULT_LOGGER.should_receive(:error)
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
          AWS::S3::S3Object.should_receive(:store).with("reports/affiliate1_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
          AWS::S3::S3Object.should_receive(:store).with("reports/affiliate2_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
          @rake[@task_name].invoke(@input_file_name, "monthly", "1000")
        end
      end

      context "when period is set to daily" do
        it "should set the report filenames using YYMMDD" do
          yymmdd = Date.yesterday.strftime('%Y%m%d')
          AWS::S3::S3Object.should_receive(:store).with("reports/affiliate1_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
          AWS::S3::S3Object.should_receive(:store).with("reports/affiliate2_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
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

    end
  end
end
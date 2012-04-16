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
        DailyQueryStat.create!(:affiliate => 'affiliate1', :query => 'query1', :times => 5, :day => Date.yesterday, :locale => 'en')
        DailyQueryStat.create!(:affiliate => 'affiliate1', :query => 'query2', :times => 7, :day => Date.yesterday, :locale => 'en')
        DailyQueryStat.create!(:affiliate => 'affiliate2', :query => 'query2', :times => 9, :day => Date.yesterday, :locale => 'en')
        @affiliate1_csv_output = ["Query,Raw Count,IP-Deduped Count","query1,11,5","query2,10,7",""].join("\n")
        @affiliate2_csv_output = ["Query,Raw Count,IP-Deduped Count","query2,22,9",""].join("\n")
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
          truncated_affiliate1_csv_output = ["Query,Raw Count,IP-Deduped Count","query1,11,5",""].join("\n")
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
  end
end
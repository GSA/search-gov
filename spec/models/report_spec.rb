require 'spec_helper'

describe Report do
  describe "#generate_report_date_range" do
    context "when period is daily" do
      let(:day) { Date.parse("2012-10-15") }
      let(:report) { Report.new("file_name", "daily", 100, day) }

      it "should return a range bounded by the input day" do
        report.generate_report_date_range.should == (day..day)
      end
    end

    context "when period is weekly" do
      context "when the input day is within the last week" do
        let(:day) { Date.current - 4 }
        let(:report) { Report.new("file_name", "weekly", 100, day) }

        it "should return a range from the input day up to yesterday " do
          report.generate_report_date_range.should == (day..Date.yesterday)
        end
      end

      context "when the input day is earlier than the last 7 days" do
        let(:day) { Date.current - 8 }
        let(:report) { Report.new("file_name", "weekly", 100, day) }

        it "should return a range from the input day up to yesterday " do
          report.generate_report_date_range.should == (day..day+6)
        end
      end
    end

    context "when period is monthly" do
      let(:day) { Date.parse("2012-10-15") }
      let(:report) { Report.new("file_name", "monthly", 100, day) }

      it "should return a range bounded by the first day of month and the input day (so we dont get any partial day data)" do
        report.generate_report_date_range.should == (day.beginning_of_month..day)
      end
    end
  end

  describe "#generate_report_filename(prefix, formatted_date)" do
    let(:day) { Date.parse("2011-02-02") }
    context "for a monthly report" do
      let(:report) { Report.new("file_name", "monthly", 100, day) }

      it "should set the report filename to the month specfied" do
        yymm = day.strftime('%Y%m')
        report.generate_report_filename("foo",yymm).should == "analytics/reports/foo/foo_top_queries_#{yymm}.csv"
      end
    end

    context "for a daily report" do
      let(:report) { Report.new("file_name", "daily", 100, day) }

      it "should set the report filename to the day specfied" do
        yymmdd = day.strftime('%Y%m%d')
        report.generate_report_filename("foo",yymmdd).should == "analytics/reports/foo/foo_top_queries_#{yymmdd}.csv"
      end
    end

    context "for a weekly report" do
      let(:report) { Report.new("file_name", "weekly", 100, day) }

      it "should set the report filename to the day specfied with _weekly in there, too" do
        yymmdd = day.strftime('%Y%m%d')
        report.generate_report_filename("foo",yymmdd).should == "analytics/reports/foo/foo_top_queries_#{yymmdd}_weekly.csv"
      end
    end
  end

  describe "#generate_top_queries_from_file" do

    before do
      AWS::S3::Base.stub!(:establish_connection).and_return true
      AWS::S3::Bucket.stub!(:find).and_return true
      AWS::S3::S3Object.stub!(:store).and_return true
      @input_file_name = ::Rails.root.to_s + "/generate_top_queries_from_file_input_file.txt"
      File.open(@input_file_name, 'w+') do |file|
        file.puts(%w{affiliate1 query1 11}.join("\001"))
        file.puts(%w{affiliate1 query2 10}.join("\001"))
        file.puts(%w{affiliate2 query2 22}.join("\001"))
        file.puts(%w{_all_ query2 32}.join("\001"))
        file.puts(%w{_all_ query1 11}.join("\001"))
      end
      DailyQueryStat.create!(:affiliate => 'affiliate1', :query => 'query1', :times => 5, :day => Date.yesterday, :locale => 'en')
      DailyQueryStat.create!(:affiliate => 'affiliate1', :query => 'query2', :times => 7, :day => Date.yesterday, :locale => 'en')
      DailyQueryStat.create!(:affiliate => 'affiliate2', :query => 'query2', :times => 9, :day => Date.yesterday, :locale => 'en')
      DailyQueryStat.create!(:affiliate => 'affiliate1', :query => 'query1', :times => 500, :day => Date.current, :locale => 'en')
      heading = "Query Term,Total Count (Bots + Humans),Real Count (Humans only)"
      @affiliate1_csv_output = [heading, "query2,10,7", "query1,11,5", ""].join("\n")
      @affiliate2_csv_output = [heading, "query2,22,9", ""].join("\n")
      @all_csv_output = [heading, "query2,32,16", "query1,11,5", ""].join("\n")
    end

    let(:report) { Report.new(@input_file_name, "monthly", 1000, Date.yesterday) }

    describe "AWS interaction" do
      it "should establish an AWS S3 connection" do
        AWS::S3::Base.should_receive(:establish_connection!).once
        report.generate_top_queries_from_file
      end

      it "should check to make sure the bucket for search reports exists" do
        AWS::S3::Bucket.should_receive(:find).with(AWS_BUCKET_NAME).once
        report.generate_top_queries_from_file
      end

      context "when the reports bucket does not exist" do
        before do
          AWS::S3::Bucket.stub!(:find).and_raise "Can't find bucket"
          AWS::S3::Bucket.stub!(:create).and_return true
        end

        it "should create the bucket if it doesn't exist" do
          AWS::S3::Bucket.should_receive(:create).with(AWS_BUCKET_NAME).once
          report.generate_top_queries_from_file
        end
      end
    end

    it "should output the CSV of the query and counts for each affiliate to a file in the AWS bucket" do
      AWS::S3::S3Object.should_receive(:store).with(anything(), @affiliate1_csv_output, AWS_BUCKET_NAME).once.ordered
      AWS::S3::S3Object.should_receive(:store).with(anything(), @affiliate2_csv_output, AWS_BUCKET_NAME).once.ordered
      AWS::S3::S3Object.should_receive(:store).with(anything(), @all_csv_output, AWS_BUCKET_NAME).once.ordered
      report.generate_top_queries_from_file
    end

    context "when period is set to monthly" do
      it "should set the report filenames using YYMM" do
        yymm = Date.yesterday.strftime('%Y%m')
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymm}.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/_all_/_all__top_queries_#{yymm}.csv", anything(), anything()).once.ordered
        report.generate_top_queries_from_file
      end
    end

    context "when the period is set to weekly" do
      let(:report) { Report.new(@input_file_name, "weekly", 1000, Date.yesterday) }

      it "should set the report filenames using yesterday as YYMMDD" do
        yymmdd = Date.yesterday.strftime('%Y%m%d')
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymmdd}_weekly.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymmdd}_weekly.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/_all_/_all__top_queries_#{yymmdd}_weekly.csv", anything(), anything()).once.ordered
        report.generate_top_queries_from_file
      end
    end

    context "when period is set to daily" do
      let(:report) { Report.new(@input_file_name, "daily", 1000, Date.yesterday) }

      it "should set the report filenames using YYMMDD" do
        yymmdd = Date.yesterday.strftime('%Y%m%d')
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate1/affiliate1_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/affiliate2/affiliate2_top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
        AWS::S3::S3Object.should_receive(:store).with("analytics/reports/_all_/_all__top_queries_#{yymmdd}.csv", anything(), anything()).once.ordered
        report.generate_top_queries_from_file
      end
    end

    context "when a group has more than max entries per group" do
      let(:report) { Report.new(@input_file_name, "daily", 1, Date.yesterday) }
      it "should truncate the output" do
        truncated_affiliate1_csv_output = ["Query Term,Total Count (Bots + Humans),Real Count (Humans only)", "query1,11,5", ""].join("\n")
        AWS::S3::S3Object.should_receive(:store).with(anything(), truncated_affiliate1_csv_output, AWS_BUCKET_NAME).once
        report.generate_top_queries_from_file
      end
    end

    context "when some problem arises" do
      before do
        DailyQueryStat.stub!(:sum).and_raise Exception
      end

      it "should skip the line and move on" do
        report.generate_top_queries_from_file
      end
    end

    after do
      File.delete(@input_file_name)
    end

  end
end
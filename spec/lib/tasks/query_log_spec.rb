require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "query_log rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/query_log"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:query_log" do

    describe "usasearch:query_log:process" do
      before do
        @task_name = "usasearch:query_log:process"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a directory of log files" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when not given a destination directory" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke(@logdir)
        end
      end

      context "when given a directory of log files" do
        before do
          @logdir = "/tmp/mydir"
          Dir.mkdir(@logdir)
          log_entry = "sdfsdf"
          @logfile = "2009-09-18-cf26.log"
          File.open("#{@logdir}/#{@logfile}", "w+") {|f| f.write(log_entry) }
          File.open("#{@logdir}/b", "w+") {|f| f.write(log_entry) }
        end

        it "should process each log file with names matching /\d{4}-\d{2}-\d{2}-.{4}\.log$/" do
          LogFile.should_receive(:process).with("#{@logdir}/#{@logfile}")
          LogFile.should_not_receive(:process).with("#{@logdir}/b")
          @rake[@task_name].invoke(@logdir, @logdir)
        end

        context "when the destination directory does not yet exist" do
          before do
            @destination_root = "/tmp"
            FileUtils.rm_r("#{@destination_root}/2009-09") if File.directory?("#{@destination_root}/2009-09")
          end

          it "should create the directory" do
            File.directory?("#{@destination_root}/2009-09").should be_false
            @rake[@task_name].invoke(@logdir, @destination_root)
            File.directory?("#{@destination_root}/2009-09").should be_true
          end

          it "should copy each log file to the destination directory based on year-month" do
            FileUtils.should_receive(:cp).with("#{@logdir}/#{@logfile}", "#{@destination_root}/2009-09")
            @rake[@task_name].invoke(@logdir, @destination_root)
          end

        end

        context "when the destination directory exists" do
          before do
            @destination_root = "/tmp"
            FileUtils.mkdir("#{@destination_root}/2009-09") unless File.directory?("#{@destination_root}/2009-09")
          end

          it "should copy each log file to the destination directory based on year-month" do
            FileUtils.should_receive(:cp).with("#{@logdir}/#{@logfile}", "#{@destination_root}/2009-09")
            @rake[@task_name].invoke(@logdir, @destination_root)
          end
        end

        after do
          FileUtils.rm_r(@logdir)
        end
      end
    end

    describe "usasearch:query_log:import" do
      before do
        @task_name = "usasearch:query_log:import"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a directory of log files" do
        it "should print out an error message" do
          RAILS_DEFAULT_LOGGER.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when given a directory of log files" do
        before do
          @logdir = "/tmp/mydir_for_import_test"
          Dir.mkdir(@logdir)
          log_entry = "doesn't matter"
          @logfiles = %w{2010_03_08_web2.log 2010_03_08_web1.log file_we_should_ignore.log}
          @logfiles.each {|logfile| File.open("#{@logdir}/#{logfile}", "w+") {|f| f.write(log_entry) } }
        end

        it "should process each log file with names that look like YYYY_MM_DD_webN.log" do
          LogFile.should_receive(:process).twice
          @rake[@task_name].invoke(@logdir)
        end

        after do
          FileUtils.rm_r(@logdir)
        end
      end
    end
  
    describe "usasearch:query_log:extract" do
      describe "usasearch:query_log:extract:clicks" do
        before do
          @task_name = "usasearch:query_log:extract:clicks"
          ENV['DAY'] = nil
          ENV['EXPORT_FILE'] = nil
          ENV['LIMIT'] = nil
          AWS::S3::Base.stub!(:establish_connection).and_return true
          AWS::S3::Bucket.stub!(:find).and_return true
          AWS::S3::S3Object.stub!(:store).and_return true
          @streamed_content = StringIO.new
          Kernel.stub!(:open).and_return @streamed_content
          File.stub!(:delete).and_return true
        end

        it "should have 'environment' as a prereq" do
          @rake[@task_name].prerequisites.should include("environment")
        end
        
        it "should default to yesterday if no date is provided, outputting to /tmp, and not use a limit" do 
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(click_ip) as click_ip, queried_at, clicked_at, url, serp_position, affiliate, results_source, user_agent FROM clicks WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND click_ip NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(clicked_at) = #{day.to_i}"
          Click.should_receive(:find_by_sql).with(sql).and_return []
          @rake[@task_name].invoke
        end
        
        it "should use a date passed in as an environment variable in place of the default" do
          day = Date.parse("2010-09-01").to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(click_ip) as click_ip, queried_at, clicked_at, url, serp_position, affiliate, results_source, user_agent FROM clicks WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND click_ip NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(clicked_at) = #{day.to_i}"
          Click.should_receive(:find_by_sql).with(sql).and_return []
          ENV["DAY"] = "20100901"
          @rake[@task_name].invoke
        end
        
        it "should usa an outfile as specified as an environment variable" do
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(click_ip) as click_ip, queried_at, clicked_at, url, serp_position, affiliate, results_source, user_agent FROM clicks WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND click_ip NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(clicked_at) = #{day.to_i}"
          Click.should_receive(:find_by_sql).with(sql).and_return []
          ENV["EXPORT_FILE"] = "/tmp/my-clicks-#{day}"
          @rake[@task_name].invoke
        end
        
        it "should include a limit if specified as an environment variable" do
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(click_ip) as click_ip, queried_at, clicked_at, url, serp_position, affiliate, results_source, user_agent FROM clicks WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND click_ip NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(clicked_at) = #{day.to_i} LIMIT 10"
          Click.should_receive(:find_by_sql).with(sql).and_return []
          ENV["LIMIT"] = "10"
          @rake[@task_name].invoke
        end
        
        it "should upload the outputted file to S3" do
          day = Date.parse('2010-09-01').to_s(:number)
          filename = 'click_logs/2010/09/clicks-20100901'
          AWS::S3::S3Object.should_receive(:store).with(filename, @streamed_content, AWS_BUCKET_NAME)
          ENV['DAY'] = day
          @rake[@task_name].invoke
        end
        
        it "should delete the locally generated outfile" do
          day = Date.yesterday.to_s(:number)
          filename = "/tmp/clicks-#{day}"
          File.should_receive(:delete).with(filename).and_return true
          @rake[@task_name].invoke
        end        
      end
      
      describe "usasearch:query_log:extract:queries" do
        before do
          @task_name = "usasearch:query_log:extract:queries"
          ENV['DAY'] = nil
          ENV['EXPORT_FILE'] = nil
          ENV['LIMIT'] = nil
          AWS::S3::Base.stub!(:establish_connection).and_return true
          AWS::S3::Bucket.stub!(:find).and_return true
          AWS::S3::S3Object.stub!(:store).and_return true
          @streamed_content = StringIO.new
          Kernel.stub!(:open).and_return @streamed_content
          File.stub!(:delete).and_return true
        end

        it "should have 'environment' as a prereq" do
          @rake[@task_name].prerequisites.should include("environment")
        end
        
        it "should default to yesterday if no date is provided, outputting to /tmp, and not use a limit" do 
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(ipaddr) as ipaddr, timestamp, affiliate, locale, agent, is_bot FROM queries WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(timestamp) = #{day.to_i}"
          Query.should_receive(:find_by_sql).with(sql).and_return []
          @rake[@task_name].invoke
        end
        
        it "should use a date passed in as an environment variable in place of the default" do
          day = Date.parse("2010-09-01").to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(ipaddr) as ipaddr, timestamp, affiliate, locale, agent, is_bot FROM queries WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(timestamp) = #{day.to_i}"
          Query.should_receive(:find_by_sql).with(sql).and_return []
          ENV["DAY"] = "20100901"
          @rake[@task_name].invoke
        end
        
        it "should use an outfile as specified as an environment variable" do
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(ipaddr) as ipaddr, timestamp, affiliate, locale, agent, is_bot FROM queries WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(timestamp) = #{day.to_i}"
          Query.should_receive(:find_by_sql).with(sql).and_return []
          ENV["EXPORT_FILE"] = "/tmp/my-queries-#{day}"
          @rake[@task_name].invoke
        end
        
        it "should include a limit if specified as an environment variable" do
          day = Date.yesterday.to_s(:number)
          sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(ipaddr) as ipaddr, timestamp, affiliate, locale, agent, is_bot FROM queries WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND date(timestamp) = #{day.to_i} LIMIT 10"
          Query.should_receive(:find_by_sql).with(sql).and_return []
          ENV["LIMIT"] = "10"
          @rake[@task_name].invoke
        end
        
        it "should upload the outputted file to S3" do
          day = Date.parse('2010-09-01').to_s(:number)
          filename = 'query_logs/2010/09/queries-20100901'
          AWS::S3::S3Object.should_receive(:store).with(filename, @streamed_content, AWS_BUCKET_NAME)
          ENV['DAY'] = day
          @rake[@task_name].invoke
        end
        
        it "should delete the locally generated outfile" do
          day = Date.yesterday.to_s(:number)
          filename = "/tmp/queries-#{day}"
          File.should_receive(:delete).with(filename).and_return true
          @rake[@task_name].invoke
        end
      end
    end
  end
end
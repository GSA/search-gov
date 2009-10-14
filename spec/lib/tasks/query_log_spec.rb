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
            FileUtils.rm_r("#{@destination_root}/2009-09")
          end

          it "should create the directory" do
            FileUtils.should_receive(:mkdir).with("#{@destination_root}/2009-09")
            @rake[@task_name].invoke(@logdir, @destination_root)
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
  end
end
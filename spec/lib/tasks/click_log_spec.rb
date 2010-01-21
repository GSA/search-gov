require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "rake"

describe "click_log rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/click_log"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:click_log" do

    describe "usasearch:click_log:process" do
      before do
        @task_name = "usasearch:click_log:process"
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
          @logdir = "/tmp/mydir"
          Dir.mkdir(@logdir)
          log_entry = "sdfsdf"
          @logfile = "2009-09-18-cf26.log"
          File.open("#{@logdir}/#{@logfile}", "w+") {|f| f.write(log_entry) }
          File.open("#{@logdir}/b", "w+") {|f| f.write(log_entry) }
        end

        it "should process each log file with names matching /\d{4}-\d{2}-\d{2}-.{4}\.log$/" do
          LogFile.should_receive(:process_clicks).with("#{@logdir}/#{@logfile}")
          LogFile.should_not_receive(:process_clicks).with("#{@logdir}/b")
          @rake[@task_name].invoke(@logdir, @logdir)
        end

        after do
          FileUtils.rm_r(@logdir)
        end
      end
    end
  end
end
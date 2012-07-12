require 'spec/spec_helper'

describe "rails3_log rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load Rails.root + "lib/tasks/rails3_log.rake"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:rails3_log" do

    describe "usasearch:rails3_log:transform_to_hive_elapsed_times_format" do
      before do
        @task_name = "usasearch:rails3_log:transform_to_hive_elapsed_times_format"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not passed a log file parameter" do
        it "should print out an error message" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
        end
      end

      context "when passed a log file parameter" do
        it "should process the log file by emitting one JSON entry per Rails3 event" do
          line1 = '{"request_url":"/search?utf8=%E2%9C%93&sc=0&query=gov","total_time":"4258","db_time":"504","view_time":"964","solr_time":"99"}'
          line2 = '{"request_url":"/?locale=en&m=false","total_time":"474","db_time":"42","view_time":"360","solr_time":"7"}'
          line3 = '{"request_url":"/sayt?q=passpor&callback=jsonp1307071011660&featureClass=P&style=full&maxRows=12&name_startsWith=passpor","total_time":"32"}'
          line4 = ''
          require 'stringio'
          $stdout = StringIO.new
          @rake[@task_name].invoke("spec/fixtures/txt/rails3_log.txt")
          $stdout.string.should == [line1, line2, line3, line4].join("\n")
        end
      end
    end

  end
end
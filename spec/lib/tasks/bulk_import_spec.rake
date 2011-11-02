require 'spec/spec_helper'

describe "Bulk Import rake tasks" do
  fixtures :users
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/bulk_import"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:bulk_import" do
    describe "usasearch:bulk_import:affiliate_csv" do
      before do
        @task_name = "usasearch:bulk_import:affiliate_csv"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end
      
      context "when no file path is specified as a paramter" do
        it "should log an error with usage information" do
          Rails.logger.should_receive(:error).with("usage: rake usasearch:bulk_import:affiliate_csv[/path/to/affiliate/csv]")
          @rake[@task_name].invoke
        end
      end
      
      context "when a file is specified" do
        before do
          Affiliate.all(:conditions => ["name LIKE ?", "test%"]).each{|aff| aff.destroy }
          @csv_file_path = File.join(Rails.root.to_s, "spec", "fixtures", "csv", "affiliate_bulk_import_sample.csv")
        end
        
        it "should create affiliates corresponding to the information in the csv, and log errors if there is a problem creating an affiliate" do
          Rails.logger.should_receive(:error).with("Unable to create affiliate with name: test3.")
          Rails.logger.should_receive(:error).with("Additional information: Site name can't be blank")
          @rake[@task_name].invoke(@csv_file_path)
          Affiliate.all(:conditions => ["name LIKE ?", "test%"]).size.should == 2
          (first_affiliate = Affiliate.find_by_name('test1')).should_not be_nil
          first_affiliate.users.count.should == 1
          first_affiliate.display_name.should == "Test 1"
          first_affiliate.domains.should == "domain1.gov\ndomain2.gov"
          (second_affiliate = Affiliate.find_by_name('test2')).should_not be_nil
          puts second_affiliate.users.inspect
          second_affiliate.users.count.should == 2
          second_affiliate.users.include?(users(:affiliate_manager)).should be_true
          second_affiliate.users.include?(users(:another_affiliate_manager)).should be_true
        end
      end
    end
  end
end
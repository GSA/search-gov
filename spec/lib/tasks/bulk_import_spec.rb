require 'spec_helper'

describe "Bulk Import rake tasks" do
  fixtures :users
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/bulk_import')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:bulk_import" do
    describe "usasearch:bulk_import:google_xml" do
      let(:task_name) { 'usasearch:bulk_import:google_xml' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      context "when a file and default user email is specified" do
        before do
          @user = users(:affiliate_manager)
          Affiliate.all(:conditions => ["name LIKE ?", "test%"]).each{|aff| aff.destroy }
          @existing_affiliate = Affiliate.create({:name => 'test1', :display_name => 'Test 1'}, :as => :test)
          @existing_affiliate.users << @user
          @existing_affiliate.site_domains << SiteDomain.new(:domain => 'domain1.gov')
          @xml_file_path = File.join(Rails.root.to_s, "spec", "fixtures", "xml", "google_bulk.xml")
        end

        it "should create affiliates corresponding to the information in the csv, and log errors if there is a problem creating an affiliate" do
          @rake[task_name].invoke(@xml_file_path, @user.email)
          Affiliate.all(:conditions => ["name LIKE ?", "test%"]).size.should == 2
          (first_affiliate = Affiliate.find_by_name('test1')).should_not be_nil
          first_affiliate.users.count.should == 1
          first_affiliate.display_name.should == "Test 1"
          first_affiliate.site_domains.collect{|site_domain| site_domain.domain }.should == ['domain1.gov', 'domain2.gov']
          (second_affiliate = Affiliate.find_by_name('test2')).should_not be_nil
          second_affiliate.users.count.should == 1
          second_affiliate.users.include?(users(:affiliate_manager)).should be_true
          second_affiliate.display_name.should == "test2"
          second_affiliate.site_domains.collect{|site_domain| site_domain.domain }.include?('domain3.gov').should be_true
        end
      end
    end
  end
end
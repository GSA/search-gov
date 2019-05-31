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
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      context 'when a file and default user email is specified' do
        before do
          @user = users(:affiliate_manager)
          Affiliate.where("name LIKE ?", "test%").each{|aff| aff.destroy }
          @existing_affiliate = Affiliate.create(name: 'test1', display_name: 'Test 1')
          @existing_affiliate.users << @user
          @existing_affiliate.site_domains << SiteDomain.new(:domain => 'domain1.gov')
          @xml_file_path = File.join(Rails.root.to_s, "spec", "fixtures", "xml", "google_bulk.xml")
        end

        it "should create affiliates corresponding to the information in the csv, and log errors if there is a problem creating an affiliate" do
          @rake[task_name].invoke(@xml_file_path, @user.email)
          expect(Affiliate.where("name LIKE ?", "test%").size).to eq(2)
          expect(first_affiliate = Affiliate.find_by_name('test1')).not_to be_nil
          expect(first_affiliate.users.count).to eq(1)
          expect(first_affiliate.display_name).to eq("Test 1")
          expect(first_affiliate.site_domains.collect{|site_domain| site_domain.domain }).to eq(['domain1.gov', 'domain2.gov'])
          expect(second_affiliate = Affiliate.find_by_name('test2')).not_to be_nil
          expect(second_affiliate.users.count).to eq(1)
          expect(second_affiliate.users.include?(users(:affiliate_manager))).to be true
          expect(second_affiliate.display_name).to eq("test2")
          expect(second_affiliate.site_domains.collect{|site_domain| site_domain.domain }.include?('domain3.gov')).to be true
        end
      end
    end

    describe "usasearch:bulk_import:affiliate_csv" do

      fixtures :affiliates
      let(:task_name) { 'usasearch:bulk_import:affiliate_csv' }
      let!(:user) { users(:non_affiliate_admin) }
      let(:csv_file_path) { File.join(Rails.root.to_s, "spec", "fixtures", "csv", "affiliates.csv") }
      let(:site) { affiliates(:usagov_affiliate) }
      let(:message) { /A script added/ }
      subject(:import_affiliates) { @rake[task_name].invoke(csv_file_path, user.email) }

      before do
        @rake[task_name].reenable
        $stdout = StringIO.new
        site.users << user
      end

      after { $stdout = STDOUT }

      it "has 'environment' as a prerequisite" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      it 'adds the user to each site' do
        expect{import_affiliates}.to change{user.affiliates.count}.by(2)
      end

      it 'logs the addition' do
        expect(Rails.logger).to receive(:info).with(message).exactly(2).times
        import_affiliates
      end

      it 'outputs a list of added sites' do
        import_affiliates
        expect($stdout.string).to match "Added user non_affiliate_admin@fixtures.org to the following sites:\nusagov: skipped - user already a member\ngobiernousa\nnoaa.gov\nnonexistent: FAILURE - site not found\n"
      end
    end
  end
end

require 'spec_helper'

describe 'Bulk Import rake tasks' do
  fixtures :users
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/bulk_import')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:bulk_import' do
    describe 'usasearch:bulk_import:affiliate_csv' do

      fixtures :affiliates
      subject(:import_affiliates) { @rake[task_name].invoke(csv_file_path, user.email) }

      let(:task_name) { 'usasearch:bulk_import:affiliate_csv' }
      let!(:user) { users(:non_affiliate_admin) }
      let(:csv_file_path) { File.join(Rails.root.to_s, 'spec', 'fixtures', 'csv', 'affiliates.csv') }
      let(:site) { affiliates(:usagov_affiliate) }
      let(:message) { /A script added/ }

      before do
        @rake[task_name].reenable
        $stdout = StringIO.new
        site.users << user
      end

      after { $stdout = STDOUT }

      it "has 'environment' as a prerequisite" do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      it 'adds the user to each site' do
        expect{ import_affiliates }.to change{ user.affiliates.count }.by(2)
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

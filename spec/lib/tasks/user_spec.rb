require 'spec_helper'

describe 'User rake tasks' do
  fixtures :users, :affiliates, :memberships

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/user')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:user:update_approval_status' do
    let(:task_name) { 'usasearch:user:update_approval_status' }
    let(:nutshell_adapter) { double(NutshellAdapter) }

    before do
      @rake[task_name].reenable
      User.destroy_all("email != 'affiliate_manager_with_no_affiliates@fixtures.org'")
      allow(NutshellAdapter).to receive(:new) { nutshell_adapter }
      allow(nutshell_adapter).to receive(:push_user)
      allow(nutshell_adapter).to receive(:new_note)
    end

    it "has 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'sets site-less users to not_approved' do
      @rake[task_name].invoke
      expect(users(:affiliate_manager_with_no_affiliates).is_not_approved?).to be true
    end

    it 'sends admin the user_approval_removed email' do
      emailer = double(Emailer)
      expect(Emailer).to receive(:user_approval_removed).with(users(:affiliate_manager_with_no_affiliates)).and_return emailer
      expect(emailer).to receive(:deliver_now)
      @rake[task_name].invoke
    end

    it 'creates a Nutshell note' do
      expected_message = 'This user is no longer associated with any sites, so their approval status has been set to "not_approved".'
      expect(nutshell_adapter).to receive(:new_note).with(users(:affiliate_manager_with_no_affiliates), expected_message)
      @rake[task_name].invoke
    end
  end
end

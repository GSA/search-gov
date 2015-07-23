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
    before do
      @rake[task_name].reenable
      User.destroy_all("email != 'affiliate_manager_with_no_affiliates@fixtures.org'")
    end

    it "has 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'sets site-less users to not_approved' do
      @rake[task_name].invoke
      expect(users(:affiliate_manager_with_no_affiliates).is_not_approved?).to be_true
    end

    it 'sends admin the user_approval_removed email' do
      emailer = mock(Emailer)
      Emailer.should_receive(:user_approval_removed).with(users(:affiliate_manager_with_no_affiliates)).and_return emailer
      emailer.should_receive(:deliver)
      @rake[task_name].invoke
    end
  end
end

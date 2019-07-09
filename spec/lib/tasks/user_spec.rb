require 'spec_helper'

describe 'User rake tasks' do
  fixtures :users, :affiliates, :memberships

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/user')
    Rake::Task.define_task(:environment)
  end

  let(:user) { users(:affiliate_manager_with_no_affiliates) }

  describe 'usasearch:user:update_approval_status' do
    let(:task_name) { 'usasearch:user:update_approval_status' }

    before do
      @rake[task_name].reenable
      User.destroy_all("email != 'affiliate_manager_with_no_affiliates@fixtures.org'")
    end

    it "has 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'sets site-less users to not_approved' do
      @rake[task_name].invoke
      expect(user.is_not_approved?).to be true
    end

    it 'sends admin the user_approval_removed email' do
      emailer = double(Emailer)
      expect(Emailer).to receive(:user_approval_removed).with(user).and_return emailer
      expect(emailer).to receive(:deliver_now)
      @rake[task_name].invoke
    end

    xit 'logs the change' do
      expected_message = <<~MESSAGE.squish
        User #{user.id}, affiliate_manager_with_no_affiliates@fixtures.org,
        is no longer associated with any sites,
        so their approval status has been set to "not_approved".
      MESSAGE

      expect(Rails.logger).to receive(:info).with(expected_message)
      @rake[task_name].invoke
    end
  end
end

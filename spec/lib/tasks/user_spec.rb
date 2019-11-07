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
  let(:not_active_user) { users(:not_active_user) }
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe 'usasearch:user:update_approval_status' do
    let(:task_name) { 'usasearch:user:update_approval_status' }

    before do
      @rake[task_name].reenable
      user_with_one_site.affiliates << affiliate
      user_with_one_site.save!
    end

    let(:user_with_one_site) { users(:affiliate_manager_with_one_site) }

    it "has 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'sets site-less users to not_approved' do
      @rake[task_name].invoke
      expect(user.is_not_approved?).to be true
    end

    it 'leaves approved users with sites as approved' do
      @rake[task_name].invoke
      expect(user_with_one_site.reload.is_approved?).to be true
    end

    it 'sends admin the user_approval_removed email' do
      User.where("email != 'affiliate_manager_with_no_affiliates@fixtures.org'").destroy_all
      emailer = double(Emailer)
      expect(Emailer).to receive(:user_approval_removed).with(user).and_return emailer
      expect(emailer).to receive(:deliver_now)
      @rake[task_name].invoke
    end

    it 'logs the change' do
      expected_message = <<~MESSAGE.squish
        User #{user.id}, affiliate_manager_with_no_affiliates@fixtures.org,
        is no longer associated with any sites,
        so their approval status has been set to "not_approved".
      MESSAGE

      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with(expected_message)
      @rake[task_name].invoke
    end
  end

  describe 'usasearch:user:update_not_active_approval_status' do
    let(:task_name) { 'usasearch:user:update_not_active_approval_status' }

    before do
      @rake[task_name].reenable
    end

    it "has 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'sets not active users to not_approved' do
      @rake[task_name].invoke
      expect(not_active_user.is_not_approved?).to be true
    end

    it 'logs the change' do
      expected_message = <<~MESSAGE.squish
        User #{not_active_user.id}, not_active_user@fixtures.org, has been not active for 90 days,
        so their approval status has been set to "not_approved".
      MESSAGE

      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with(expected_message)
      @rake[task_name].invoke
    end
  end
end

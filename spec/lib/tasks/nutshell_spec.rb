require 'spec_helper'

describe 'Nutshell rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/nutshell')
    Rake::Task.define_task(:environment)
  end

  let(:adapter) { mock(NutshellAdapter) }

  before { NutshellAdapter.stub(:new) { adapter } }

  describe 'usasearch:nutshell:push_users' do
    let(:task_name) { 'usasearch:nutshell:push_users' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should push all users' do
      user = mock_model(User)
      User.should_receive(:all).and_return([user])
      adapter.should_receive(:push_user).with(user)

      @rake[task_name].invoke
    end
  end

  describe 'usasearch:nutshell:push_users_without_nutshell_id' do
    let(:task_name) { 'usasearch:nutshell:push_users_without_nutshell_id' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should push all users' do
      user_without_nutshell_id = mock_model(User)
      User.should_receive(:where).with(nutshell_id: nil).and_return([user_without_nutshell_id])
      adapter.should_receive(:push_user).with(user_without_nutshell_id)

      @rake[task_name].invoke
    end
  end

  describe 'usasearch:nutshell:push_sites' do
    let(:task_name) { 'usasearch:nutshell:push_sites' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should push all sites' do
      site = mock_model(Affiliate)
      Affiliate.should_receive(:all).and_return([site])
      adapter.should_receive(:push_site).with(site)

      @rake[task_name].invoke
    end
  end
end

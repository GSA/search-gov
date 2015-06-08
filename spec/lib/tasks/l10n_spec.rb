require 'spec_helper'

describe 'Localization rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/l10n')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:l10n:update_navigable_names' do
    let(:task_name) { 'usasearch:l10n:update_navigable_names' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should update navigable names with translations from locale files' do
      navigable_name_updater = mock(NavigableNameUpdater)
      NavigableNameUpdater.should_receive(:new).and_return(navigable_name_updater)
      navigable_name_updater.should_receive(:update)
      @rake[task_name].invoke
    end
  end
end

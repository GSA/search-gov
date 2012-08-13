require 'spec_helper'

describe 'forms rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/forms')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:forms:import' do
    let(:task_name) { 'usasearch:forms:import' }
    before { @rake[task_name].reenable }

    it 'should import uscis forms' do
      UscisForm.should_receive(:import)
      @rake[task_name].invoke
    end
  end
end


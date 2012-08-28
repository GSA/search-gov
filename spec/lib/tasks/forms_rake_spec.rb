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
    let(:rocis_hash) { mock('rocis hash') }
    let(:rocis_data) { mock('rocis data', :to_hash => rocis_hash) }
    let(:ssa_form) { mock('ssa form') }
    let(:uscis_form) { mock('uscis form') }

    before { @rake[task_name].reenable }

    it 'should import uscis forms' do
      RocisData.should_receive(:new).and_return(rocis_data)
      SsaForm.should_receive(:new).with(rocis_hash).and_return(ssa_form)
      ssa_form.should_receive(:import)
      UscisForm.should_receive(:new).with(rocis_hash).and_return(uscis_form)
      uscis_form.should_receive(:import)
      @rake[task_name].invoke
    end
  end
end


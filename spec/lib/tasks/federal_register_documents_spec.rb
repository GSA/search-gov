require 'spec_helper'

describe 'Federal register documents rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/federal_register_documents')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:federal_register_documents:import' do
    let(:task_name) { 'usasearch:federal_register_documents:import' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include('environment')
    end

    it 'should import federal register documents' do
      FederalRegisterDocumentData.should_receive(:import).with(load_all: false)
      @rake[task_name].invoke
    end

    context 'when load_all=true is specified' do
      it 'import with load_all: true' do
        FederalRegisterDocumentData.should_receive(:import).with(load_all: true)
        @rake[task_name].invoke('load_all=true')
      end
    end
  end
end

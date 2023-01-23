require 'spec_helper'

describe 'Federal register rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/federal_register')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:federal_register:import_agencies' do
    let(:task_name) { 'usasearch:federal_register:import_agencies' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should import federal register agencies' do
      expect(FederalRegisterAgencyData).to receive(:import)
      @rake[task_name].invoke
    end
  end

  describe 'usasearch:federal_register:import_documents' do
    let(:task_name) { 'usasearch:federal_register:import_documents' }

    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    it 'should import federal register documents' do
      expect(FederalRegisterDocumentData).to receive(:import).with(load_all: false)
      @rake[task_name].invoke
    end

    context 'when load_all=true is specified' do
      it 'import with load_all: true' do
        expect(FederalRegisterDocumentData).to receive(:import).with(load_all: true)
        @rake[task_name].invoke('load_all=true')
      end
    end
  end
end

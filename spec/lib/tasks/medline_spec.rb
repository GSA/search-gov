require 'spec_helper'

describe 'Medline rake tasks' do

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/medline')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:medline:load' do
    let(:task_name) { 'usasearch:medline:load' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      expect(@rake[task_name].prerequisites).to include('environment')
    end

    context 'when given a date' do
      it 'should download and process medline xml file' do
        mock_file_path = double('file path')
        expect(MedTopic).to receive(:download_medline_xml).
            with(Date.parse('2011-04-26')).
            and_return(mock_file_path)
        expect(MedTopic).to receive(:process_medline_xml).with(mock_file_path)
        @rake[task_name].invoke('2011-04-26')
      end
    end

    context 'when given no date' do
      it 'should download and process medline xml file' do
        mock_file_path = double('file path')
        expect(MedTopic).to receive(:download_medline_xml).
            with(nil).
            and_return(mock_file_path)
        expect(MedTopic).to receive(:process_medline_xml).with(mock_file_path)
        @rake[task_name].invoke
      end
    end
  end
end

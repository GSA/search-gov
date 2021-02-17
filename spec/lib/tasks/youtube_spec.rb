# frozen_string_literal: true

describe 'YouTube rake tasks' do
  let(:rake) { Rake::Application.new }

  before do
    Rake.application = rake
    $LOADED_FEATURES.reject! { |f| f == 'tasks/youtube.rake' }
    rake.rake_require('tasks/youtube')
  end

  describe 'usasearch:youtube:refresh' do
    let(:task_name) { 'usasearch:youtube:refresh' }

    it "has 'environment' as a prerequisite" do
      expect(rake[task_name].prerequisites).to include('environment')
    end

    describe 'when invoked' do
      before do
        allow(YoutubeData).to receive(:refresh)
        Rake::Task.define_task(:environment)
        rake[task_name].invoke
      end

      it 'runs YoutubeData.refresh' do
        expect(YoutubeData).to have_received(:refresh)
      end
    end
  end
end

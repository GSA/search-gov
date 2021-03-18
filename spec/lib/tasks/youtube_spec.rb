# frozen_string_literal: true

describe 'YouTube rake tasks' do
  before(:all) { Rails.application.load_tasks }

  describe 'usasearch:youtube:refresh' do
    let(:task_name) { 'usasearch:youtube:refresh' }

    before { allow(YoutubeData).to receive(:refresh) }

    after { Rake::Task[task_name].reenable }

    it "has 'environment' as a prereq" do
      expect(Rake::Task[task_name].prerequisites).to include('environment')
    end

    it 'runs YoutubeData.refresh' do
      Rake::Task[task_name].invoke
      expect(YoutubeData).to have_received :refresh
    end
  end
end

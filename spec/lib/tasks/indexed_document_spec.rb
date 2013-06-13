require 'spec_helper'

describe "Indexed document rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/indexed_document')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:indexed_document:refresh" do
    let(:task_name) { 'usasearch:indexed_document:refresh' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    context "when the extent argument is passed in" do
      it "should fetch/index affiliate indexed documents based on the argument passed in" do
        IndexedDocument.should_receive(:refresh).once.with("not_ok")
        @rake[task_name].invoke('not_ok')
      end
    end

  end

end

require 'spec_helper'

describe "Indexed domain rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/indexed_domain')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:indexed_domain:detect_templates" do
    let(:task_name) { 'usasearch:indexed_domain:detect_templates' }

    it "should try to detect common templates for all indexed domains" do
      IndexedDomain.should_receive(:detect_templates)
      @rake[task_name].invoke
    end
  end

end

require 'spec_helper'

describe "Flickr rake tasks" do
  fixtures :affiliates
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/flickr')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:flickr:import_photos" do
    let(:task_name) { 'usasearch:flickr:import_photos' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should call import photos for all affiliates" do
      affiliates = [affiliates(:basic_affiliate), affiliates(:power_affiliate)]
      Affiliate.should_receive(:all).and_return affiliates
      affiliates.first.should_receive(:import_flickr_photos).and_return true
      affiliates.last.should_receive(:import_flickr_photos).and_return true
      @rake[task_name].invoke
    end
  end

end

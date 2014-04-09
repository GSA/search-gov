require 'spec_helper'

describe "Flickr rake tasks" do
  fixtures :flickr_profiles
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
      flickr_profiles = [flickr_profiles(:user), flickr_profiles(:group)]
      FlickrProfile.should_receive(:all).and_return flickr_profiles
      flickr_profiles.first.should_receive(:import_photos).and_return true
      flickr_profiles.last.should_receive(:import_photos).and_return true
      @rake[task_name].invoke
    end
  end

end

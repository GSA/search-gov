require 'spec_helper'

describe "synonyms rake tasks" do
  fixtures :affiliates

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/synonyms')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:synonyms" do

    describe "usasearch:synonyms:mine" do
      let(:task_name) { 'usasearch:synonyms:mine' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      context "when days_back are specified" do
        it "should mine synonyms based on last X days worth of SaytSuggestions per affiliate" do
          days_back = 7
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, days_back)
          end
          @rake[task_name].invoke(days_back)
        end
      end

      context "when days_back is not specified" do
        it "should mine synonyms based on SaytSuggestions per affiliate updated over last day" do
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, 1)
          end
          @rake[task_name].invoke
        end
      end
    end

  end
end

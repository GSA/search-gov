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

      context "when words_per_affiliate and months_back are specified" do
        it "should mine synonyms based on top X words per affiliate over last Y months" do
          words_per_affiliate, months_back = 101, 7
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, words_per_affiliate, months_back)
          end
          @rake[task_name].invoke(words_per_affiliate, months_back)
        end
      end

      context "when words_per_affiliate and months_back are not specified" do
        it "should mine synonyms based on top 100 words per affiliate over last 2 months" do
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, 100, 2)
          end
          @rake[task_name].invoke
        end
      end
    end

  end
end

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

      context "when min_popularity is specified" do
        it "should mine synonyms based SaytSuggestions with a popularity of at least X" do
          min_popularity = 7
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, min_popularity)
          end
          @rake[task_name].invoke(min_popularity)
        end
      end

      context "when min_popularity is not specified" do
        it "should mine synonyms based SaytSuggestions with a popularity of at least 10" do
          Affiliate.pluck(:id).each do |affiliate_id|
            Resque.should_receive(:enqueue).with(SynonymMiner, affiliate_id, 10)
          end
          @rake[task_name].invoke
        end
      end
    end

    describe "usasearch:synonyms:group_overlapping_synonyms" do
      before do
        Synonym.create_entry_for(['internal revenue service', 'irs'], affiliates(:basic_affiliate))
        Synonym.create_entry_for(['visa', 'visas'], affiliates(:gobiernousa_affiliate))
      end

      let(:task_name) { 'usasearch:synonyms:group_overlapping_synonyms' }

      it 'should group overlapping synonyms per locale per status' do
        Synonym.should_receive(:group_overlapping_synonyms).with('en', 'Approved')
        Synonym.should_receive(:group_overlapping_synonyms).with('es', 'Approved')
        Synonym.should_receive(:group_overlapping_synonyms).with('en', 'Candidate')
        Synonym.should_receive(:group_overlapping_synonyms).with('es', 'Candidate')
        @rake[task_name].invoke
      end
    end

  end
end

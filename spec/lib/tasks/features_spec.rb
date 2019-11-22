require 'spec_helper'

describe "Features-related rake tasks" do
  fixtures :affiliates, :features, :users

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/features')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:features" do
    describe "usasearch:features:record_feature_usage" do
      let(:task_name) { 'usasearch:features:record_feature_usage' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      context "when not given a data file or feature internal name" do
        it "should print out an error message" do
          expect(Rails.logger).to receive(:error)
          @rake[task_name].invoke
        end
      end

      context "when given a data file and feature internal name" do
        before do
          AffiliateFeatureAddition.delete_all
          @a1 = affiliates(:basic_affiliate)
          @a2 = affiliates(:power_affiliate)
          @f1 = features(:disco)
          @a1.features << @f1
          @input_file_name = ::Rails.root.to_s + "/affiliate_feature_addition.txt"
          File.open(@input_file_name, 'w+') do |file|
            file.puts(@a1.id)
            file.puts(@a2.id)
          end
        end

        it "should create AffiliateFeatureAdditions for new affiliate IDs for that feature, ignoring dupes" do
          expect(@f1.affiliates.size).to eq(1)
          expect(@f1.affiliates.first).to eq(@a1)
          @rake[task_name].invoke(@f1.internal_name, @input_file_name)
          expect(@f1.affiliates.size).to eq(2)
          expect(@f1.affiliates.last).to eq(@a2)
        end

        after do
          File.delete(@input_file_name)
        end
      end
    end

    describe "usasearch:features:email_admin_about_new_feature_usage" do
      let(:task_name) { 'usasearch:features:email_admin_about_new_feature_usage' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      context "when there is info to email" do
        it "should call the Emailer's new feature additions method" do
          emailer = double(Emailer)
          expect(Emailer).to receive(:new_feature_adoption_to_admin).and_return emailer
          expect(emailer).to receive(:deliver_now)
          @rake[task_name].invoke
        end
      end

      context "when there is no info to email" do
        before do
          AffiliateFeatureAddition.delete_all
        end

        it "should handle the nil email" do
          @rake[task_name].invoke
        end
      end
    end

  end
end

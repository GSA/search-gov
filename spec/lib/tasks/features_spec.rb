require 'spec/spec_helper'

describe "Features-related rake tasks" do
  fixtures :affiliates, :features, :users
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/features"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:features" do
    describe "usasearch:features:record_feature_usage" do
      before do
        @task_name = "usasearch:features:record_feature_usage"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when not given a data file or feature internal name" do
        it "should print out an error message" do
          Rails.logger.should_receive(:error)
          @rake[@task_name].invoke
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
          @f1.affiliates.size.should == 1
          @f1.affiliates.first.should == @a1
          @rake[@task_name].invoke(@f1.internal_name, @input_file_name)
          @f1.affiliates.size.should == 2
          @f1.affiliates.last.should == @a2
        end

        after do
          File.delete(@input_file_name)
        end
      end
    end

    describe "usasearch:features:email_admin_about_new_feature_usage" do
      before do
        @task_name = "usasearch:features:email_admin_about_new_feature_usage"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when there is info to email" do
        it "should call the Emailer's new feature additions method" do
          emailer = mock(Emailer)
          Emailer.should_receive(:new_feature_adoption_to_admin).and_return emailer
          emailer.should_receive(:deliver)
          @rake[@task_name].invoke
        end
      end

      context "when there is no info to email" do
        before do
          AffiliateFeatureAddition.delete_all
        end

        it "should handle the nil email" do
          @rake[@task_name].invoke
        end
      end
    end

    describe "usasearch:features:user_feature_reminder" do
      before do
        @task_name = "usasearch:features:user_feature_reminder"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      describe "created_days_back param" do
        context "when a created_days_back param is not specified" do
          it "should default to 3 days" do
            target_day = 3.days.ago
            User.should_receive(:where).with(["created_at between ? and ?", target_day.beginning_of_day, target_day.end_of_day]).and_return []
            @rake[@task_name].invoke
          end
        end

        context "when a created_days_back param is specified" do
          it "should use the param" do
            target_day = 10.days.ago
            User.should_receive(:where).with(["created_at between ? and ?", target_day.beginning_of_day, target_day.end_of_day]).and_return []
            @rake[@task_name].invoke(10)
          end
        end
      end

      context "when there are newish users" do
        let(:lazy_user) { users(:affiliate_manager) }
        let(:ambitious_user) { users(:another_affiliate_manager) }

        before do
          AffiliateFeatureAddition.delete_all
          ambitious_user.affiliates.each { |a| a.features << Feature.all }
          User.stub!(:where).and_return [lazy_user, ambitious_user]
          @emailer = mock(Emailer)
          @emailer.stub!(:deliver).and_return true
        end

        it "should email the ones with affiliates with unimplemented features" do
          Emailer.should_receive(:feature_admonishment).once.with(lazy_user, lazy_user.affiliates).and_return @emailer
          @rake[@task_name].invoke
        end
      end
    end
  end
end
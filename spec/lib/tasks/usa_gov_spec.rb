require 'spec_helper'

describe "USA.gov rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/usa_gov')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:crawl_usa_gov" do
    let(:task_name) { 'usasearch:crawl_usa_gov' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should initiate the crawling/scraping of USA.gov" do
      SitePage.should_receive(:crawl_usa_gov).once
      @rake[task_name].invoke
    end
  end

  describe "usasearch:crawl_answers_usa_gov" do
    let(:task_name) { 'usasearch:crawl_answers_usa_gov' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it "should initiate the crawling/scraping of USA.gov" do
      SitePage.should_receive(:crawl_answers_usa_gov).once
      @rake[task_name].invoke
    end
  end

  describe "usasearch:detect_objectionable_content" do
    let(:task_name) { 'usasearch:detect_objectionable_content' }
    before { @rake[task_name].reenable }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    context "when always-filtered search terms do not generate search results on adult-enabled SERPs" do
      before do
        SaytFilter.create!(:phrase => "bad_term", :always_filtered => true)
        usagov_affiliate = Affiliate.find_by_name Affiliate::USAGOV_AFFILIATE_NAME
        WebSearch.should_receive(:results_present_for?).with("bad_term", usagov_affiliate, true, "off").and_return false
      end

      it "should not send an alert email" do
        Emailer.should_not_receive(:objectionable_content_alert)
        @rake[task_name].invoke
      end
    end

    context "when always filtered search terms generate search results on adult-enabled SERPs" do
      before do
        good_term = "this is ok"
        bad_term = "really bad phrase"
        SaytFilter.create!(:phrase => good_term, :always_filtered => false)
        SaytFilter.create!(:phrase => bad_term, :always_filtered => true)
        WebSearch.stub!(:results_present_for?).and_return true
        @array = [bad_term]
      end

      context "when no email recipient is passed in" do
        it "should default to a manager's email" do
          emailer = mock("Emailer")
          Emailer.should_receive(:objectionable_content_alert).once.with("amy.farrajfeijoo@gsa.gov", @array).and_return emailer
          emailer.should_receive(:deliver)
          @rake[task_name].invoke
        end
      end

      context "when email recipient is passed in" do
        it "should use that email address" do
          emailer = mock("Emailer")
          Emailer.should_receive(:objectionable_content_alert).once.with("foo@bar.com", @array).and_return emailer
          emailer.should_receive(:deliver)
          @rake[task_name].invoke("foo@bar.com")
        end
      end
    end
  end

end

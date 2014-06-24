require 'spec_helper'

describe "Report generation rake tasks" do
  fixtures :users, :affiliates, :memberships

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/reports')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:reports" do

    describe 'usasearch:reports:daily_snapshot' do
      let(:task_name) { 'usasearch:reports:daily_snapshot' }

      before do
        @rake[task_name].reenable
        @emailer = mock(Emailer)
        @emailer.stub!(:deliver).and_return true
        Membership.stub(:daily_snapshot_receivers).and_return %w(foo bar)
      end

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      it "should deliver an email to each daily_snapshot_receiver" do
        Emailer.should_receive(:daily_snapshot).with('foo').and_return @emailer
        Emailer.should_receive(:daily_snapshot).with('bar').and_return @emailer
        @rake[task_name].invoke
      end

    end

    describe "usasearch:reports:email_monthly_reports" do
      let(:task_name) { 'usasearch:reports:email_monthly_reports' }

      before do
        @rake[task_name].reenable
        @emailer = mock(Emailer)
        @emailer.stub!(:deliver).and_return true
      end

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      it "should deliver an email to each user" do
        Emailer.should_receive(:affiliate_monthly_report).with(anything(), Date.yesterday).exactly(2).times.and_return @emailer
        @rake[task_name].invoke
      end

      context "when a year/month is passed as a parameter" do
        it "should deliver the affiliate monthly report to each user with the specified date" do
          Emailer.should_receive(:affiliate_monthly_report).with(anything(), Date.parse('2012-04-01')).exactly(2).times.and_return @emailer
          @rake[task_name].invoke("2012-04")
        end
      end
    end

    describe "usasearch:reports:email_yearly_reports" do
      let(:task_name) { 'usasearch:reports:email_yearly_reports' }

      before do
        @rake[task_name].reenable
        @emailer = mock(Emailer)
        @emailer.stub!(:deliver).and_return true
      end

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      it "should deliver an email to each user" do
        Emailer.should_receive(:affiliate_yearly_report).with(anything(), Date.current.year).exactly(2).times.and_return @emailer
        @rake[task_name].invoke
      end

      context "when a year is passed as a parameter" do
        it "should deliver the affiliate yearly report to each user for the specified year" do
          Emailer.should_receive(:affiliate_yearly_report).with(anything(), 2011).exactly(2).times.and_return @emailer
          @rake[task_name].invoke("2011")
        end
      end

      context "when Emailer raises an exception" do
        it "should log it and proceed to the next user" do
          Emailer.should_receive(:affiliate_yearly_report).with(anything(), Date.current.year).exactly(2).times.and_raise Net::SMTPFatalError
          Rails.logger.should_receive(:warn).exactly(2).times
          @rake[task_name].invoke
        end
      end
    end
  end
end

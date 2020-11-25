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
      let(:membership1) { mock_model(Membership, user_id: 42) }
      let(:membership2) { mock_model(Membership, user_id: 43) }

      before do
        @rake[task_name].reenable
        @emailer = double(Emailer)
        allow(@emailer).to receive(:deliver_now).and_return true
        allow(Membership).to receive(:daily_snapshot_receivers).and_return [membership1, membership2]
      end

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      it "should deliver an email to each daily_snapshot_receiver" do
        expect(Emailer).to receive(:daily_snapshot).with(membership1).and_return @emailer
        expect(Emailer).to receive(:daily_snapshot).with(membership2).and_return @emailer
        @rake[task_name].invoke
      end

      context "when Emailer raises an exception" do
        it "should log it and proceed to the next user" do
          expect(Emailer).to receive(:daily_snapshot).with(anything()).exactly(2).times.and_raise Net::SMTPFatalError
          expect(Rails.logger).to receive(:warn).exactly(2).times
          @rake[task_name].invoke
        end
      end
    end

    describe "usasearch:reports:email_monthly_reports" do
      let(:task_name) { 'usasearch:reports:email_monthly_reports' }
      let(:expected_number_of_report_recepients) do
        User.approved_affiliate.
          to_a.
          select { |u| u.affiliates.present? }.
          count
      end

      before do
        @rake[task_name].reenable
        @emailer = double(Emailer)
        allow(@emailer).to receive(:deliver_now).and_return true
      end

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      it "should deliver an email to each user" do
        expect(Emailer).to receive(:affiliate_monthly_report).
                             with(anything(), Date.yesterday).
                             exactly(expected_number_of_report_recepients).times.
                             and_return @emailer
        @rake[task_name].invoke
      end

      context "when a year/month is passed as a parameter" do
        it "should deliver the affiliate monthly report to each user with the specified date" do
          expect(Emailer).to receive(:affiliate_monthly_report).
                               with(anything(), Date.parse('2012-04-01')).
                               exactly(expected_number_of_report_recepients).
                               times.
                               and_return @emailer
          @rake[task_name].invoke("2012-04")
        end
      end

      context "when Emailer raises an exception" do
        it "should log it and proceed to the next user" do
          expect(Emailer).to receive(:affiliate_monthly_report).
                               with(anything(), Date.parse('2012-04-01')).
                               exactly(expected_number_of_report_recepients).times.
                               and_raise Net::SMTPFatalError
          expect(Rails.logger).to receive(:warn).
                                    exactly(expected_number_of_report_recepients).times
          @rake[task_name].invoke("2012-04")
        end
      end
    end

    describe "usasearch:reports:email_yearly_reports" do
      let(:task_name) { 'usasearch:reports:email_yearly_reports' }
      let(:expected_number_of_report_recepients) do
        User.approved_affiliate.
          to_a.
          select { |u| u.affiliates.present? }.
          count
      end

      before do
        @rake[task_name].reenable
        @emailer = double(Emailer)
        allow(@emailer).to receive(:deliver_now).and_return true
      end

      it "should have 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include("environment")
      end

      it "should deliver an email to each user" do
        expect(Emailer).to receive(:affiliate_yearly_report).
                             with(anything(), Date.current.year).
                             exactly(expected_number_of_report_recepients).times.
                             and_return @emailer
        @rake[task_name].invoke
      end

      context "when a year is passed as a parameter" do
        it "should deliver the affiliate yearly report to each user for the specified year" do
          expect(Emailer).to receive(:affiliate_yearly_report).
                               with(anything(), 2011).
                               exactly(expected_number_of_report_recepients).times.
                               and_return @emailer
          @rake[task_name].invoke("2011")
        end
      end

      context "when Emailer raises an exception" do
        it "should log it and proceed to the next user" do
          expect(Emailer).to receive(:affiliate_yearly_report).
                               with(anything(), Date.current.year).
                               exactly(expected_number_of_report_recepients).times.
                               and_raise Net::SMTPFatalError
          expect(Rails.logger).to receive(:warn).exactly(expected_number_of_report_recepients).times
          @rake[task_name].invoke
        end
      end
    end
  end
end

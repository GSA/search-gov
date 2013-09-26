require 'spec_helper'

describe Sites::MonthlyReportsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when affiliate is looking at monthly report data' do
      include_context 'approved user logged in to a site'

      let(:monthly_report) { double('MonthlyReport') }

      context 'when valid target month passed in' do
        before do
          MonthlyReport.should_receive(:new).with(site, '2012', '09').and_return monthly_report
          get :show, mmyyyy: '09/2012'
        end

        it { should assign_to(:monthly_report).with(monthly_report) }
      end

      context 'when no target month passed in' do
        it 'should default to yesterdays month' do
          MonthlyReport.should_receive(:new).with(site, Date.yesterday.strftime('%Y'), Date.yesterday.strftime('%m')).and_return monthly_report
          get :show
        end
      end

      context 'when invalid target month passed in' do
        before do
          get :show, mmyyyy: 'blah'
        end

        it { should assign_to(:monthly_report).with_kind_of(MonthlyReport) }

        it 'should default to beginning of yesterdays month' do
          assigns[:monthly_report].picked_date.should == Date.yesterday.beginning_of_month
        end

      end
    end
  end
end

require 'spec_helper'

describe Sites::MonthlyReportsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when affiliate is looking at legacy monthly report data' do
      include_context 'approved user logged in to a site'

      let(:monthly_report) { double('MonthlyReport') }

      context 'when valid target month passed in' do
        before do
          AWS::S3::Base.stub!(:establish_connection!).and_return true
          MonthlyReport.should_receive(:new).with(site, '2012', '09').and_return monthly_report
          get :show, mmyyyy: '09/2012'
        end

        it { should assign_to(:monthly_report).with(monthly_report) }
      end

    end
    
    context 'when affiliate is looking at monthly report data' do
      include_context 'approved user logged in to a site'

      let(:rtu_monthly_report) { double('RtuMonthlyReport') }

      context 'when valid target month passed in' do
        before do
          RtuMonthlyReport.should_receive(:new).with(site, '2014', '06', current_user.sees_filtered_totals).and_return rtu_monthly_report
          get :show, mmyyyy: '06/2014'
        end

        it { should assign_to(:monthly_report).with(rtu_monthly_report) }
      end

      context 'when no target month passed in' do
        it 'should default to todays month' do
          RtuMonthlyReport.should_receive(:new).
            with(site, Date.current.strftime('%Y'), Date.current.strftime('%m'), current_user.sees_filtered_totals).
            and_return rtu_monthly_report
          get :show
        end
      end

      context 'when invalid target month passed in' do
        before do
          get :show, mmyyyy: 'blah'
        end

        it { should assign_to(:monthly_report).with_kind_of(RtuMonthlyReport) }

        it 'should default to beginning of todays month' do
          assigns[:monthly_report].picked_date.should == Date.current.beginning_of_month
        end

      end
    end
  end
end

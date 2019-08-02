require 'spec_helper'

describe Sites::MonthlyReportsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, site_id: 100

    context 'when affiliate is looking at monthly report data' do
      include_context 'approved user logged in to a site'

      let(:rtu_monthly_report) { double('RtuMonthlyReport') }

      context 'when valid target month passed in' do
        before do
          expect(RtuMonthlyReport).to receive(:new).with(site, '2014', '06', current_user.sees_filtered_totals).and_return rtu_monthly_report
          get :show, parms: { mmyyyy: '06/2014', site_id: site.id }
        end

        it { is_expected.to assign_to(:monthly_report).with(rtu_monthly_report) }
      end

      context 'when no target month passed in' do
        it 'should default to todays month' do
          expect(RtuMonthlyReport).to receive(:new).
            with(site, Date.current.strftime('%Y'), Date.current.strftime('%m'), current_user.sees_filtered_totals).
            and_return rtu_monthly_report
          get :show, params: { site_id: site.id }
        end
      end

      context 'when invalid target month passed in' do
        before do
          get :show, params: { mmyyyy: 'blah', site_id: site.id }
        end

        it { is_expected.to assign_to(:monthly_report).with_kind_of(RtuMonthlyReport) }

        it 'should default to beginning of todays month' do
          expect(assigns[:monthly_report].picked_date).to eq(Date.current.beginning_of_month)
        end

      end
    end
  end
end

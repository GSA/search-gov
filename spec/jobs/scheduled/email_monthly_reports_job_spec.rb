# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::EmailMonthlyReportsJob do
  fixtures :users, :affiliates, :memberships

  subject(:perform) { described_class.perform_now }

  let(:emailer) { double(Emailer, deliver: true) }
  let(:approved_affiliates_with_sites_count) do
    User.approved_affiliate.count { |user| user.affiliates.present? }
  end

  it 'delivers a monthly report to each approved affiliate user with sites' do
    expect(Emailer).to receive(:affiliate_monthly_report).
      with(anything, Date.yesterday).
      exactly(approved_affiliates_with_sites_count).times.
      and_return(emailer)
    perform
  end

  context 'when a year/month is passed' do
    it 'uses the specified report date' do
      expect(Emailer).to receive(:affiliate_monthly_report).
        with(anything, Date.parse('2012-04-01')).
        exactly(approved_affiliates_with_sites_count).times.
        and_return(emailer)
      described_class.perform_now('2012-04')
    end
  end

  context 'when Emailer raises' do
    it 'logs and continues' do
      expect(Emailer).to receive(:affiliate_monthly_report).
        with(anything, Date.parse('2012-04-01')).
        exactly(approved_affiliates_with_sites_count).times.
        and_raise(Net::SMTPFatalError)
      expect(Rails.logger).to receive(:warn).
        exactly(approved_affiliates_with_sites_count).times
      described_class.perform_now('2012-04')
    end
  end
end

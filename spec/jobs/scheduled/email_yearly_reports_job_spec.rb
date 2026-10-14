# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::EmailYearlyReportsJob do
  fixtures :users, :affiliates, :memberships

  subject(:perform) { described_class.perform_now }

  let(:emailer) { double(Emailer, deliver: true) }
  let(:approved_affiliates_with_sites_count) do
    User.approved_affiliate.count { |user| user.affiliates.present? }
  end

  it 'delivers a yearly report to each approved affiliate user with sites' do
    expect(Emailer).to receive(:affiliate_yearly_report).
      with(anything, Date.current.year).
      exactly(approved_affiliates_with_sites_count).times.
      and_return(emailer)
    perform
  end

  context 'when a year is passed' do
    it 'uses the specified year' do
      expect(Emailer).to receive(:affiliate_yearly_report).
        with(anything, 2011).
        exactly(approved_affiliates_with_sites_count).times.
        and_return(emailer)
      described_class.perform_now('2011')
    end
  end

  context 'when Emailer raises' do
    it 'logs and continues' do
      expect(Emailer).to receive(:affiliate_yearly_report).
        with(anything, Date.current.year).
        exactly(approved_affiliates_with_sites_count).times.
        and_raise(Net::SMTPFatalError)
      expect(Rails.logger).to receive(:warn).
        exactly(approved_affiliates_with_sites_count).times
      perform
    end
  end
end

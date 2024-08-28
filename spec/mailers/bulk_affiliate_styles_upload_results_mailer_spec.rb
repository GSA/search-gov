require 'spec_helper'

describe BulkAffiliateStylesUploadResultsMailer do
  describe '#results_email' do
    let(:user) { users(:affiliate_admin) }
    let(:filename) { 'test_file.csv' }
    let(:results) do
      results = BulkAffiliateStyles::Results.new(filename)
      results.add_ok(1)
      results.add_ok(2)
      results
    end
    let(:mail) { described_class.with(user:, results:).results_email }

    it 'has the correct subject' do
      expect(mail.subject).to eq("Bulk affiliate styles upload results for #{filename}")
    end

    it 'has the correct recepient' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct from header' do
      expect(mail.from).to eq([DELIVER_FROM_EMAIL_ADDRESS])
    end

    it 'has the correct reply-to' do
      expect(mail.reply_to).to eq([SUPPORT_EMAIL_ADDRESS])
    end

    it 'has the correct total number of URLs' do
      expect(mail.body.encoded).to match(/There were #{results.total_count} affiliates/)
    end
  end
end

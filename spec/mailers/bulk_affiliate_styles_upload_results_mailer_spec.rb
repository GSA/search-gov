require 'spec_helper'

describe BulkAffiliateStylesUploadResultsMailer do
  describe '#results_email' do
    let(:user) { users(:affiliate_admin) }
    let(:results) { instance_double('Results', file_name: 'test_file.csv') }
    let(:mail) { described_class.with(user: user, results: results).results_email }

    it 'renders the headers' do
      expect(mail.subject).to eq("Bulk affiliate styles upload results for test_file.csv")
      expect(mail.to).to eq(['user@example.com'])
      expect(mail.from).to eq([Rails.configuration.action_mailer.default_options[:from]])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Bulk affiliate styles upload results for test_file.csv")
    end
  end
end

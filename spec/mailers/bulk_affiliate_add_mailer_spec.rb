# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkAffiliateAddMailer, type: :mailer do
  let(:email) { 'test@example.com' }
  let(:file_name) { 'bulk_add_test.csv' }
  let(:from_email) { [DELIVER_FROM_EMAIL_ADDRESS] }
  let(:reply_to_email) { [SUPPORT_EMAIL_ADDRESS] }

  describe '#notify' do
    let(:added_sites) { ['Affiliate1', 'Affiliate2'] }
    let(:failed_additions) { [['Affiliate3', 'Not Found'], ['Affiliate4', 'Error occurred']] }
    let(:mail) { described_class.notify(email, file_name, added_sites, failed_additions) }
    let(:mail_body) { mail.body.encoded }

    it 'renders the correct subject' do
      expect(mail.subject).to eq("Bulk Affiliate Add Results for #{file_name}")
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([email])
    end

    it 'sends from the correct sender email' do
      expect(mail.from).to eq(from_email)
    end

    it 'has the correct reply-to address' do
      expect(mail.reply_to).to eq(reply_to_email)
    end

    it 'includes added sites in the email body' do
      added_sites.each do |site|
        expect(mail_body).to include(site)
      end
    end

    it 'includes failed additions with their respective error messages in the email body' do
      failed_additions.each do |affiliate, error|
        expect(mail_body).to match(/#{affiliate}.*#{error}/)
      end
    end
  end

  describe '#notify_parsing_failure' do
    let(:general_errors) { ['File missing required columns', 'Rows contain invalid data'] }
    let(:error_details) { [{ identifier: 'Row 2', error: 'Missing Affiliate name' }, { identifier: 'Row 5', error: 'Invalid characters' }] }
    let(:mail) { described_class.notify_parsing_failure(email, file_name, general_errors, error_details) }
    let(:mail_body) { mail.body.encoded }

    it 'renders the correct subject' do
      expect(mail.subject).to eq("Bulk Affiliate Add Failed for #{file_name}")
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([email])
    end

    it 'sends from the correct sender email' do
      expect(mail.from).to eq(from_email)
    end

    it 'has the correct reply-to address' do
      expect(mail.reply_to).to eq(reply_to_email)
    end

    it 'includes general errors in the email body' do
      general_errors.each do |error|
        expect(mail_body).to include(error)
      end
    end

    it 'includes error details with identifiers and messages in the email body' do
      error_details.each do |detail|
        expect(mail_body).to match(/#{detail[:identifier]}.*#{detail[:error]}/)
      end
    end
  end
end

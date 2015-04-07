require 'spec_helper'

describe NutshellParamsBuilder do
  class NutshellParamsBuilderTester
    include NutshellParamsBuilder
  end

  let(:builder) { NutshellParamsBuilderTester.new }

  describe '#edit_contact_email_params' do
    let(:user) do
      mock_model(User,
                 approval_status: 'approved',
                 contact_name: 'Mary Jane',
                 id: 8,
                 email: 'mary.jane@EMAIL.gov')
    end

    context 'when contact_email Hash is present and it does not include User#email' do
      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                        'email' => { '0' => 'mjane@email.gov',
                                     '--primary' => 'mjane@email.gov' },
                        'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      it 'returns params' do
        expect(builder.edit_contact_email_params(user, contact)).
          to eq(contactId: 600,
                contact: {
                  email: {
                    '0' => 'mary.jane@EMAIL.gov',
                    '1' => 'mjane@email.gov' } },
                rev: '10')
      end
    end

    context 'when contact_email Hash is present and it includes User#email' do
      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                        'email' => { '0' => 'mjane@email.gov',
                                     '1' => 'Mary.Jane@email.gov',
                                     '--primary' => 'mjane@email.gov' },
                        'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      it 'returns nil' do
        expect(builder.edit_contact_email_params(user, contact)).to be_nil
      end
    end

    context 'when contact_email Array is present and it does not include User#email' do
      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                        'email' => %w(mjane@email.gov),
                        'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      it 'returns params' do
        expect(builder.edit_contact_email_params(user, contact)).
          to eq(contactId: 600,
                contact: {
                  email: {
                    '0' => 'mary.jane@EMAIL.gov',
                    '1' => 'mjane@email.gov' } },
                rev: '10')
      end
    end

    context 'when contact_email Array is present and it includes User#email' do
      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                        'email' => %w(mjane@email.gov Mary.Jane@email.gov),
                        'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      it 'returns nil' do
        expect(builder.edit_contact_email_params(user, contact)).to be_nil
      end
    end

    context 'when contact_email is not present' do
      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                        'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      it 'returns params' do
        expect(builder.edit_contact_email_params(user, contact)).
          to eq(contactId: 600,
                contact: {
                  email: { '0' => 'mary.jane@EMAIL.gov' } },
                rev: '10')
      end
    end
  end

  describe '#extract_contact_emails' do
    context 'when contact emails is a Hash' do
      it 'removes invalid emails' do
        contact_emails = {
          '0' => '',
          '1' => 'user1@email.gov',
          '2' => 'user2@email.gov',
          '3' => nil
        }

        expect(builder.extract_contact_emails(contact_emails)).
          to eq(%w(user1@email.gov user2@email.gov))
      end
    end
  end
end

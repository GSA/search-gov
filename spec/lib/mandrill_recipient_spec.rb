require 'spec_helper'

describe MandrillRecipient do
  subject { described_class.new(user, config, merge_vars) }

  let(:config) { { some: 'config' } }
  let(:user) do
    affiliates = [
      mock_model(Affiliate, name: 'Site Beyond Site'),
    ]
    mock_model(User,
               id: 21,
               email: 'user@example.com',
               email_verification_token: 'verification-token',
               contact_name: 'Some User',
               organization_name: 'The Organization',
               requires_manual_approval?: true,
               affiliates: affiliates)
  end

  describe '.new' do
    let(:merge_vars) { { verify_url: 'http://example.com' } }

    its(:user) { should == user }
    its(:config) { should == config }
    its(:merge_vars) { should == merge_vars}
  end

  describe '#to_user' do
    let(:merge_vars) { { } }
    let(:config) { { bcc_email: bcc_email } }

    context 'when there is no bcc_email configured' do
      let(:bcc_email) { nil }

      it 'includes just the user as a recipient' do
        expect(subject.to_user).to eq [
          { email: 'user@example.com', name: 'Some User' }
        ]
      end
    end

    context 'when there is a bcc_email configured' do
      let(:bcc_email) { 'bcc@example.com' }

      it 'includes the user and bcc as recipients' do
        expect(subject.to_user).to eq [
          { email: 'user@example.com', name: 'Some User' },
          { email: 'bcc@example.com', type: 'bcc' },
        ]
      end
    end
  end

  describe '#to_admin' do
    let(:merge_vars) { { } }
    let(:config) do
      {
        admin_email: 'admin@example.com',
        bcc_email: bcc_email,
      }
    end

    context 'when there is no bcc_email configured' do
      let(:bcc_email) { nil }

      it 'includes just the admin as recipient' do
        expect(subject.to_admin).to eq [
          { email: 'admin@example.com' },
        ]
      end
    end

    context 'when there is a bcc_email configured' do
      let(:bcc_email) { 'bcc@example.com' }

      it 'includes the admin and bcc as recipients' do
        expect(subject.to_admin).to eq [
          { email: 'admin@example.com' },
          { email: 'bcc@example.com', type: 'bcc' },
        ]
      end
    end
  end

  describe '#user_merge_vars_array' do
    let(:config) { { bcc_email: bcc_email } }

    context 'when no merge_vars are provided' do
      let(:merge_vars) { { } }
      let(:expected_merge_vars) do
        [
          { name: 'contact_name', content: 'Some User' },
          { name: 'email', content: 'user@example.com' },
          { name: 'email_verification_token', content: 'verification-token' },
          { name: 'has_sites', content: true },
          { name: 'id', content: 21 },
          { name: 'latest_site', content: 'Site Beyond Site' },
          { name: 'organization_name', content: 'The Organization' },
          { name: 'requires_manual_approval', content: true },
        ]
      end

      context 'and there is no bcc_email configured' do
        let(:bcc_email) { nil }

        it 'includes standard user merge vars sorted by name for just the user' do
          expect(subject.user_merge_vars_array).to eq [
            {
              rcpt: 'user@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end

      context 'and there is a bcc_email configured' do
        let(:bcc_email) { 'bcc@example.com' }

        it 'includes the standard user merge vars sorted by name for both user and bcc' do
          expect(subject.user_merge_vars_array).to eq [
            {
              rcpt: 'user@example.com',
              vars: expected_merge_vars,
            },
            {
              rcpt: 'bcc@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end
    end

    context 'when merge_vars are provided' do
      let(:merge_vars) do
        {
          token: 'token-value',
          organization_name: 'Some Other Organization',
        }
      end
      let(:expected_merge_vars) do
        [
          { name: 'contact_name', content: 'Some User' },
          { name: 'email', content: 'user@example.com' },
          { name: 'email_verification_token', content: 'verification-token' },
          { name: 'has_sites', content: true },
          { name: 'id', content: 21 },
          { name: 'latest_site', content: 'Site Beyond Site' },
          { name: 'organization_name', content: 'Some Other Organization' },
          { name: 'requires_manual_approval', content: true },
          { name: 'token', content: 'token-value' },
        ]
      end

      context 'and there is no bcc_email configured' do
        let(:bcc_email) { nil }

        it 'includes the given merge vars and standard user merge vars sorted by name for just the user' do
          expect(subject.user_merge_vars_array).to eq [
            {
              rcpt: 'user@example.com',
              vars: expected_merge_vars,
            },
          ]
        end

      end

      context 'and there is a bcc_email configured' do
        let(:bcc_email) { 'bcc@example.com' }

        it 'includes the given merge vars and standard user merge vars sorted by name for both user and bcc' do
          expect(subject.user_merge_vars_array).to eq [
            {
              rcpt: 'user@example.com',
              vars: expected_merge_vars,
            },
            {
              rcpt: 'bcc@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end
    end
  end

  describe '#admin_merge_vars_array' do
    let(:config) do
      {
        admin_email: 'admin@example.com',
        bcc_email: bcc_email,
      }
    end

    context 'when no merge_vars are provided' do
      let(:merge_vars) { { } }
      let(:expected_merge_vars) do
        [
          { name: 'contact_name', content: 'Some User' },
          { name: 'email', content: 'user@example.com' },
          { name: 'email_verification_token', content: 'verification-token' },
          { name: 'has_sites', content: true },
          { name: 'id', content: 21 },
          { name: 'latest_site', content: 'Site Beyond Site' },
          { name: 'organization_name', content: 'The Organization' },
          { name: 'requires_manual_approval', content: true },
        ]
      end

      context 'and there is no bcc_email configured' do
        let(:bcc_email) { nil }

        it 'includes standard admin-facing user merge vars sorted by name for just the admin' do
          expect(subject.admin_merge_vars_array).to eq [
            {
              rcpt: 'admin@example.com',
              vars: expected_merge_vars,
            },
          ]
        end

      end

      context 'and there is a bcc_email configured' do
        let(:bcc_email) { 'bcc@example.com' }

        it 'includes standard admin-facing user merge vars sorted by name for both the admin and bcc' do
          expect(subject.admin_merge_vars_array).to eq [
            {
              rcpt: 'admin@example.com',
              vars: expected_merge_vars,
            },
            {
              rcpt: 'bcc@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end
    end

    context 'when merge_vars are provided' do
      let(:merge_vars) do
        {
          token: 'token-value',
          organization_name: 'Some Other Organization',
        }
      end
      let(:expected_merge_vars) do
        [
          { name: 'contact_name', content: 'Some User' },
          { name: 'email', content: 'user@example.com' },
          { name: 'email_verification_token', content: 'verification-token' },
          { name: 'has_sites', content: true },
          { name: 'id', content: 21 },
          { name: 'latest_site', content: 'Site Beyond Site' },
          { name: 'organization_name', content: 'Some Other Organization' },
          { name: 'requires_manual_approval', content: true },
          { name: 'token', content: 'token-value' },
        ]
      end

      context 'and there is no bcc_email configured' do
        let(:bcc_email) { nil }

        it 'includes the given merge vars and standard user merge vars sorted by name for just the admin' do
          expect(subject.admin_merge_vars_array).to eq [
            {
              rcpt: 'admin@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end

      context 'and there is a bcc_email configured' do
        let(:bcc_email) { 'bcc@example.com' }

        it 'includes the given merge vars and standard user merge vars sorted by name for both admin and bcc' do
          expect(subject.admin_merge_vars_array).to eq [
            {
              rcpt: 'admin@example.com',
              vars: expected_merge_vars,
            },
            {
              rcpt: 'bcc@example.com',
              vars: expected_merge_vars,
            },
          ]
        end
      end
    end
  end
end

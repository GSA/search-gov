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

    it 'includes the user as recipient' do
      expect(subject.to_user).to eq [{ email: 'user@example.com', name: 'Some User' }]
    end
  end

  describe '#to_admin' do
    let(:merge_vars) { { } }
    let(:config) { { admin_email: 'admin@example.com' } }

    it 'includes just admin as recipient' do
      expect(subject.to_admin).to eq [{ email: 'admin@example.com' }]
    end
  end

  describe '#user_merge_vars_array' do
    let(:merge_vars) { { } }

    it 'includes standard user merge vars sorted by name' do
      expect(subject.user_merge_vars_array).to eq [
        {
          rcpt: 'user@example.com',
          vars: [
            { name: 'contact_name', content: 'Some User' },
            { name: 'email', content: 'user@example.com' },
            { name: 'email_verification_token', content: 'verification-token' },
            { name: 'has_sites', content: true },
            { name: 'id', content: 21 },
            { name: 'latest_site', content: 'Site Beyond Site' },
            { name: 'organization_name', content: 'The Organization' },
            { name: 'requires_manual_approval', content: true },
          ],
        },
      ]
    end

    context 'when merge_vars are provided' do
      let(:merge_vars) do
        {
          token: 'token-value',
          organization_name: 'Some Other Organization',
        }
      end

      it 'includes the given merge vars and standard user merge vars sorted by name' do
        expect(subject.user_merge_vars_array).to eq [
          {
            rcpt: 'user@example.com',
            vars: [
              { name: 'contact_name', content: 'Some User' },
              { name: 'email', content: 'user@example.com' },
              { name: 'email_verification_token', content: 'verification-token' },
              { name: 'has_sites', content: true },
              { name: 'id', content: 21 },
              { name: 'latest_site', content: 'Site Beyond Site' },
              { name: 'organization_name', content: 'Some Other Organization' },
              { name: 'requires_manual_approval', content: true },
              { name: 'token', content: 'token-value' },
            ],
          },
        ]
      end
    end
  end

  describe '#admin_merge_vars_array' do
    let(:config) { { admin_email: 'admin@example.com' } }
    let(:merge_vars) { { } }

    it 'includes standard admin-facing user merge vars sorted by name' do
      expect(subject.admin_merge_vars_array).to eq [
        {
          rcpt: 'admin@example.com',
          vars: [
            { name: 'contact_name', content: 'Some User' },
            { name: 'email', content: 'user@example.com' },
            { name: 'email_verification_token', content: 'verification-token' },
            { name: 'has_sites', content: true },
            { name: 'id', content: 21 },
            { name: 'latest_site', content: 'Site Beyond Site' },
            { name: 'organization_name', content: 'The Organization' },
            { name: 'requires_manual_approval', content: true },
          ],
        },
      ]
    end

    context 'when merge_vars are provided' do
      let(:merge_vars) do
        {
          token: 'token-value',
          organization_name: 'Some Other Organization',
        }
      end

      it 'includes the given merge vars and standard user merge vars sorted by name' do
        expect(subject.admin_merge_vars_array).to eq [
          {
            rcpt: 'admin@example.com',
            vars: [
              { name: 'contact_name', content: 'Some User' },
              { name: 'email', content: 'user@example.com' },
              { name: 'email_verification_token', content: 'verification-token' },
              { name: 'has_sites', content: true },
              { name: 'id', content: 21 },
              { name: 'latest_site', content: 'Site Beyond Site' },
              { name: 'organization_name', content: 'Some Other Organization' },
              { name: 'requires_manual_approval', content: true },
              { name: 'token', content: 'token-value' },
            ],
          },
        ]
      end
    end
  end
end

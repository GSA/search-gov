require 'spec_helper'

describe MandrillAdapter do
  subject(:adapter) { described_class.new(config) }

  before { allow(Mandrill::API).to receive(:new).and_return(client) }
  let(:client) { double(Mandrill::API, messages: messages, templates: templates) }
  let(:messages) { double(Mandrill::Messages) }
  let(:templates) { double(Mandrill::Templates) }

  let(:user) { mock_model(User) }

  describe '.new' do
    let(:config) { { some: 'config' } }

    its(:config) { should == config }
  end

  describe '#client' do
    context 'when there is an api_key in the config' do
      let(:config) { { api_key: 'key' } }

      its(:client) { should be_present }
    end

    context 'when there is no api_key in the config' do
      let(:config) { { something: 'else' } }

      its(:client) { should be_nil }
    end
  end

  describe '#smtp_settings' do
    let(:config) do
      {
        some: 'config',
        api_username: api_username,
        api_key: api_key,
      }
    end

    context 'when there is no api_username or api_key in the config' do
      let(:api_username) { nil }
      let(:api_key) { nil }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is an api_username but no api_key in the config' do
      let(:api_username) { 'username' }
      let(:api_key) { nil }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is an api_key but no api_username in the config' do
      let(:api_username) { nil }
      let(:api_key) { 'key' }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is both an api_username and api_key in the config' do
      let(:api_username) { 'configured_username' }
      let(:api_key) { 'configured_key' }

      its(:smtp_settings) do
        should eq({
          address: 'smtp.mandrillapp.com',
          port: 587,
          enable_starttls_auto: true,
          user_name: 'configured_username',
          password: 'configured_key',
          authentication: 'login',
        })
      end
    end
  end

  describe "#force_to" do
    context 'with no force_to configured (default)' do
      let(:config) { { } }
      its(:force_to) { should be_nil }
    end

    context 'with force_to configured' do
      let(:email_trap) { 'emailtrap@somewhere.gov' }
      let(:config) { { force_to: email_trap } }
      its(:force_to) { should eq email_trap }
    end
  end

  describe 'sending email' do
    let(:config) do
      {
        admin_email: 'admin@example.com',
        from_email: 'from@example.com',
        from_name: 'The Team',
        api_key: 'key',
      }
    end

    context 'with no client configured' do
      let(:client) { nil }

      describe '#send_user_email' do
        it 'does not send any email' do
          allow_message_expectations_on_nil
          expect(client).not_to receive(:messages)

          adapter.send_user_email(user, 'template_name', { merge: 'vars' })
        end
      end

      describe '#send_admin_email' do
        it 'does not send any email' do
          allow_message_expectations_on_nil
          expect(client).not_to receive(:messages)

          adapter.send_admin_email(user, 'template_name', { merge: 'vars' })
        end
      end
    end

    context 'with the client configured' do
      let(:merge_vars) { { some_field: 'some value' } }
      let(:recipient) do
        double(MandrillRecipient,
            to_user: [{ email: 'user@example.com', name: 'Some User' }],
            user_merge_vars_array: { user: 'vars' },
            to_admin: [{ email: 'admin@example.com' }],
            admin_merge_vars_array: { admin: 'vars' })
      end

      before { allow(MandrillRecipient).to receive(:new).and_return(recipient) }

      describe '#send_user_email' do
        let(:expected_message) do
          {
            to: [{ email: 'user@example.com', name: 'Some User' }],
            merge_vars: { user: 'vars' },
            from_email: 'from@example.com',
            from_name: 'The Team',
            inline_css: true,
            track_opens: false,
            global_merge_vars: [],
          }
        end

        it 'sends email with the user as recipient' do
          expect(messages).to receive(:send_template).with('template_name', [], expected_message)

          adapter.send_user_email(user, 'template_name', merge_vars)
        end

        context 'when an invalid mandrill api key is used' do
          it 'absorbs the error' do
            allow(messages).to receive(:send_template).with('template_name', [], expected_message).and_raise(Mandrill::InvalidKeyError)

            expect { adapter.send_user_email(user, 'template_name', merge_vars) }.not_to raise_error
          end
        end
      end

      describe '#send_admin_email' do
        context 'when there is no admin_email in the config' do
          let(:config) { { api_key: 'key' } }

          it 'does not send any email' do
            allow_message_expectations_on_nil
            expect(client).not_to receive(:messages)

            adapter.send_admin_email(user, 'template_name', { merge: 'vars' })
          end
        end

        context 'when there is an admin_email in the config' do
          let(:expected_message) do
            {
              to: [{ email: 'admin@example.com' }],
              merge_vars: { admin: 'vars' },
              from_email: 'from@example.com',
              from_name: 'The Team',
              inline_css: true,
              track_opens: false,
              global_merge_vars: [],
            }
          end

          it 'sends email with the admin_email as recipient' do
            expect(messages).to receive(:send_template).with('template_name', [], expected_message)

            adapter.send_admin_email(user, 'template_name', merge_vars)
          end

          context 'when an invalid mandrill api key is used' do
            it 'absorbs the error' do
              allow(messages).to receive(:send_template).with('template_name', [], expected_message).and_raise(Mandrill::InvalidKeyError)

              expect { adapter.send_admin_email(user, 'template_name', merge_vars) }.not_to raise_error
            end
          end
        end
      end
    end
  end

  describe 'browsing templates' do
    context 'with no client configured' do
      let(:client) { nil }
      let(:config) { { } }

      describe '#templates' do
        it 'raises an exception' do
          expect { adapter.template_names }.to raise_error(MandrillAdapter::NoClient)
        end
      end

      describe '#preview_info' do
        it 'raises an exception' do
          expect { adapter.template_names }.to raise_error(MandrillAdapter::NoClient)
        end
      end
    end

    context 'with a client configured' do
      let(:config) do
        {
          admin_email: 'admin@example.com',
          api_key: 'key',
        }
      end

      describe '#template_names' do
        before do
          template_hashes = [
            { 'name' => 'Template A' },
            { 'name' => 'Template B' },
          ]
          expect(templates).to receive(:list).and_return(template_hashes)
        end

        it 'fetches template names from mandrill' do
          expect(adapter.template_names).to eq(['Template A', 'Template B'])
        end
      end

      describe '#preview_info' do
        let(:user) do
          affiliates = [
            mock_model(Affiliate, name: 'Site Beyond Site'),
          ]
          mock_model(User,
                     id: 21,
                     email: 'user@example.com',
                     email_verification_token: 'verification-token',
                     contact_name: 'Some User',
                     requires_manual_approval?: true,
                     affiliates: affiliates)
        end

        before do
          expect(templates).to receive(:list).and_return([template])
        end

        context 'when the named template has an admin label' do
          let(:template) do
            {
              'name' => 'Template A',
              'subject' => 'Email Subject',
              'labels' => ['admin'],
              'code' => 'Dear *|FIRST|* *|LAST|*, welcome to *|CONTACT_NAME|*.',
            }
          end

          it 'produces an admin preview' do
            expected_preview = {
              to: 'admin@example.com',
              subject: 'Email Subject',
              to_admin: true,
              merge_tags: {
                available: {
                  contact_name: 'Some User',
                },
                needed: [
                  :first,
                  :last,
                ],
              },
            }
            expect(adapter.preview_info(user, 'Template A')).to eq(expected_preview)
          end
        end

        context 'when the named template does not have an admin label' do
          let(:template) do
            {
              'name' => 'Template A',
              'subject' => 'Email Subject',
              'labels' => [],
              'code' => 'Dear *|FIRST|* *|LAST|*, welcome to *|CONTACT_NAME|*.',
            }
          end

          it 'produces a user preview' do
            expected_preview = {
              to: 'Some User <user@example.com>',
              subject: 'Email Subject',
              to_admin: false,
              merge_tags: {
                available: {
                  contact_name: 'Some User',
                },
                needed: [
                  :first,
                  :last,
                ],
              },
            }
            expect(adapter.preview_info(user, 'Template A')).to eq(expected_preview)
          end
        end
      end
    end
  end
end

require 'spec_helper'

describe NutshellAdapter do
  let(:client) { double(NutshellClient) }
  subject(:adapter) { described_class.new }

  before { NutshellClient.stub(:new).and_return(client) }

  describe '#initialize' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      its(:client) { should be_present }
    end

    context 'when NutshellClient is disabled' do
      before { NutshellClient.stub(:enabled?).and_return(false) }

      its(:client) { should be_nil }
    end
  end

  describe '#push_user' do
    context 'when User#nutshell_id is present' do
      it 'sends NutshellClient#edit_contact' do
        user = mock_model(User, nutshell_id?: true)
        adapter.should_receive(:edit_contact).with(user)

        adapter.push_user user
      end
    end

    context 'when User#nutshell_id is not present' do
      it 'sends NutshellClient#new_contact' do
        user = mock_model(User, nutshell_id?: false)
        adapter.should_receive(:new_contact).with(user)

        adapter.push_user user
      end
    end
  end

  describe '#new_contact' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:contact) do
        get_contact_body_hash = {
          'result' =>
            { 'id' => 600,
              'email' => {
                '0' => 'mjane@email.gov',
                '1' => 'mary.jane@email.gov',
                '--primary' => 'mjane@email.gov' },
              'rev' => '10' }
        }
        Hashie::Mash::Rash.new(get_contact_body_hash).result
      end

      let(:user) do
        mock_model(User,
                   nutshell_approval_status: 'approved',
                   contact_name: 'Mary Jane',
                   id: 8,
                   email: 'mary.jane@email.gov')
      end

      let(:expected_nutshell_params) do
        { contact: {
            email: %w(mary.jane@email.gov),
            name: 'Mary Jane',
            customFields: {
              :'Approval status' => 'approved',
              :'Super Admin URL' => 'https://search.usa.gov/admin/users?search[id]=8'
            }
          }
        }
      end

      context 'when contact with matching email does not exist' do
        let(:response_body) do
          body_hash = {
            'result' => { 'id' => 600 }
          }

          Hashie::Mash::Rash.new(body_hash)
        end

        before do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(nil)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_contact, expected_nutshell_params).
            and_return([true, response_body])

          user_arel = double('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).
            with(nutshell_id: 600, updated_at: kind_of(Time))
          user.should_receive(:nutshell_id=).with(600)

          adapter.new_contact user
        end
      end

      context 'when contact with matching email exists' do
        before do
          user_arel = double('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).
            with(nutshell_id: 600, updated_at: kind_of(Time))
          user.should_receive(:nutshell_id=).with(600)
        end

        it 'calls NutshellAdapter#edit_contact' do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(contact)
          adapter.should_receive(:edit_contact).with(user)

          adapter.new_contact user
        end
      end

      context 'when new_contact returns with error' do
        let(:response_body) do
          body_hash = {
            'error' => {
              'code' => -32600,
              'message' => 'Missing required parameter',
              'data' => nil
            },
            'result' => nil
          }

          Hashie::Mash::Rash.new(body_hash)
        end

        before do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(nil)
        end

        it 'skips User#update_attributes' do
          client.should_receive(:post).
            with(:new_contact, expected_nutshell_params).
            and_return([false, response_body])

          user.should_not_receive(:update_attributes)

          adapter.new_contact user
        end
      end
    end
  end

  describe '#edit_contact' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:user) do
        mock_model(User,
                   nutshell_approval_status: 'pending_email_verification',
                   contact_name: 'Mary Jane',
                   email: 'mary.jane@email.gov',
                   id: 8,
                   nutshell_id: 600)
      end

      let(:expected_non_email_params) do
        { contactId: 600,
          rev: 'REV_IGNORE',
          contact: {
            customFields: {
              :'Approval status' => 'pending_email_verification',
              :'Super Admin URL' => 'https://search.usa.gov/admin/users?search[id]=8'
            },
            name: 'Mary Jane'
          }
        }
      end

      let(:contact_body) do
        contact_body_hash = {
          'result' => {
            'id' => 600,
            'email' => {
              '0' => 'mjane@email.gov',
              '--primary' => 'mjane@email.gov' },
            'rev' => '1' }
        }
        Hashie::Mash::Rash.new(contact_body_hash)
      end

      context 'when User#email does not exist in the Contact' do
        it 'sends edit_contact requests' do
          client.should_receive(:post).
            with(:edit_contact, expected_non_email_params).
            and_return([true, contact_body])

          expected_email_params = {
            contactId: 600,
            rev: '1',
            contact: {
              email: { '0' => 'mary.jane@email.gov',
                       '1' => 'mjane@email.gov' }
            }
          }

          client.should_receive(:post).
            with(:edit_contact, expected_email_params).
            and_return([true, contact_body])

          adapter.edit_contact user
        end
      end

      context 'when User#email exists in the Contact' do
        let(:user_with_matching_email) do
          mock_model(User,
                     nutshell_approval_status: 'pending_email_verification',
                     contact_name: 'Mary Jane',
                     email: 'mjane@email.gov',
                     id: 8,
                     nutshell_id: 600)
        end

        it 'sends edit_contact request' do
          client.should_receive(:post).
            with(:edit_contact, expected_non_email_params).
            and_return([true, contact_body])

          adapter.edit_contact user_with_matching_email
        end
      end

      context 'when edit_contact returns with "Invalid contact" error message' do
        before do
          error_body_hash = {
            'result' => nil,
            'error' => {
              'code' => -32600,
              'message' => 'Invalid contact: 600',
              'data' => nil
            },
            'id' => 'apeye',
            'jsonrpc' => '2.0'
          }

          error_body = Hashie::Mash::Rash.new error_body_hash
          client.should_receive(:post).
            with(:edit_contact, expected_non_email_params).
            and_return([false, error_body])
        end

        it 'sets User#nutshell_id to nil' do
          user_arel = double('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).
            with(nutshell_id: nil, updated_at: kind_of(Time))
          user.should_receive(:nutshell_id=).with(nil)

          adapter.edit_contact user
        end
      end
    end
  end

  describe '#get_contact' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      context 'when result is present' do
        let(:contact_body) do
          get_contact_body_hash = {
            'result' =>
              { 'id' => 600,
                'email' => {
                  '0' => 'mjane@email.gov',
                  '--primary' => 'mjane@email.gov' },
                'rev' => '1' }
          }
          Hashie::Mash::Rash.new(get_contact_body_hash)
        end

        it 'returns the contact' do
          client.should_receive(:post).
            with(:get_contact, contactId: 600).
            and_return([true, contact_body])

          expect(adapter.get_contact(600)).to eq(contact_body.result)
        end
      end

      context 'when result is not present' do
        let(:response_body) do
          get_contact_body_hash = {
            'error' => nil,
            'id' => 'dae8a43ec',
            'jsonrpc' => '2.0',
            'result' => nil
          }

          Hashie::Mash::Rash.new(get_contact_body_hash)
        end

        it 'returns nil' do
          client.should_receive(:post).
            with(:get_contact, contactId: 600).
            and_return([true, response_body])

          expect(adapter.get_contact(600)).to eq(nil)
        end
      end
    end
  end

  describe '#get_contact_by_email' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      context 'when result is present and the email matches' do
        let(:search_contacts_response_body) do
          response_hash = {
            'result' => [
              {
                'stub' => true,
                'id' => 600,
                'entityType' => 'Contacts',
                'name' => 'Mary Jane',
              }
            ],
            'id' => 'apeye',
            'error' => nil,
            'jsonrpc' => '2.0'
          }

          Hashie::Mash::Rash.new response_hash
        end

        let(:get_contact_response_body) do
          get_contact_body_hash = {
            'result' =>
              { 'id' => 600,
                'email' => {
                  '0' => 'mjane@email.gov',
                  '1' => 'Mary.Jane@email.gov',
                  '--primary' => 'mjane@email.gov' },
                'rev' => '1' }
          }
          Hashie::Mash::Rash.new get_contact_body_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@EMAIL.gov', 1]).
            and_return([true, search_contacts_response_body])

          adapter.should_receive(:get_contact).
            with(600).
            and_return(get_contact_response_body.result)
        end

        it 'returns matching contact' do
          expect(adapter.get_contact_by_email('mary.jane@EMAIL.gov')).
            to eq(get_contact_response_body.result)
        end
      end

      context 'when result is not present' do
        let(:search_contacts_response_body) do
          response_hash = {
            'result' => [],
            'id' => 'apeye',
            'error' => nil,
            'jsonrpc' => '2.0'
          }

          Hashie::Mash::Rash.new response_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@email.gov', 1]).
            and_return([true, search_contacts_response_body])

          adapter.should_not_receive(:get_contact)
        end

        it 'returns matching contact' do
          expect(adapter.get_contact_by_email('mary.jane@email.gov')).to be_nil
        end
      end

      context 'when result is present and the email matches' do
        let(:search_contacts_response_body) do
          response_hash = {
            'result' => [
              {
                'stub' => true,
                'id' => 600,
                'entityType' => 'Contacts',
                'name' => 'Not Mary Jane',
              }
            ],
            'id' => 'apeye',
            'error' => nil,
            'jsonrpc' => '2.0'
          }

          Hashie::Mash::Rash.new response_hash
        end

        let(:get_contact_response_body) do
          get_contact_body_hash = {
            'result' => {
              'id' => 600,
              'email' => {
                '0' => 'mjane@email.gov',
                '--primary' => 'mjane@email.gov' },
              'rev' => '1' }
          }
          Hashie::Mash::Rash.new get_contact_body_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@email.gov', 1]).
            and_return([true, search_contacts_response_body])

          adapter.should_receive(:get_contact).
            with(600).
            and_return(get_contact_response_body.result)
        end

        it 'returns matching contact' do
          expect(adapter.get_contact_by_email('mary.jane@email.gov')).to be_nil
        end
      end
    end
  end

  describe '#push_site' do
    context 'when Affiliate#nutshell_id is present' do
      it 'sends NutshellClient#edit_lead' do
        site = mock_model(Affiliate, nutshell_id?: true)
        adapter.should_receive(:edit_lead).with(site)

        adapter.push_site site
      end
    end

    context 'when Affiliate#nutshell_id is not present' do
      it 'sends NutshellClient#new_lead' do
        site = mock_model(Affiliate, nutshell_id?: false)
        adapter.should_receive(:new_lead).with(site)

        adapter.push_site site
      end
    end
  end

  describe '#new_lead' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:expected_nutshell_params) {
        {
          lead: {
            contacts: [ { id: 600 }],
            createdTime: '2015-02-01T05:00:00+00:00',
            customFields: {
              :'Admin Center URL' => 'https://search.usa.gov/sites/3000',
              :'Homepage URL' => 'https://search.digitalgov.gov',
              :'Previous month query count' => 0,
              :'SERP URL' => 'https://search.usa.gov/search?affiliate=usasearch',
              :'Site handle' => 'usasearch',
              :'Super Admin URL' => 'https://search.usa.gov/admin/affiliates?search[id]=3000'
            },
            description: '(usasearch) DigitalGov Search An Official Website of the U.S. Government Office of Citizen...'
          }
        }
      }

      let(:user) do
        mock_model(User,
                   contact_name: 'Mary Jane',
                   email: 'mary.jane@email.gov',
                   nutshell_id: 600)
      end

      let(:site) do
        mock_model(Affiliate,
                   created_at: Time.parse('2015-02-01 05:00:00 UTC'),
                   display_name: 'DigitalGov  Search An Official Website of the U.S. Government Office of Citizen Services & Innovative Technologies',
                   id: 3000,
                   last_month_query_count: 0,
                   name: 'usasearch',
                   users: double('Users', pluck: [600, 600]),
                   website: 'https://search.digitalgov.gov')
      end

      context 'when NutshellClient#new_lead is successful' do
        let(:response_body) do
          body_hash = {
            result: { id: 777 }
          }

          Hashie::Mash::Rash.new(body_hash)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_lead, expected_nutshell_params).
            and_return([true, response_body])

          site.should_receive(:update_attributes).with(nutshell_id: 777)

          adapter.new_lead site
        end
      end

      context 'when NutshellClient#new_lead returns with error' do
        let(:response_body) do
          body_hash = {
            'error' => {
              'code' => -32600,
              'message' => 'Missing required parameter',
              'data' => nil
            },
            'result' => nil,
          }

          Hashie::Mash::Rash.new(body_hash)
        end

        it 'skips Site#update_attributes' do
          client.should_receive(:post).
            with(:new_lead, expected_nutshell_params).
            and_return([false, response_body])

          site.should_not_receive(:update_attributes)
          adapter.should_not_receive(:push_user)

          adapter.new_lead site
        end
      end
    end
  end

  describe '#edit_lead' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:site) do
        mock_model(Affiliate,
                   created_at: Time.parse('2015-02-01 05:00:00 UTC'),
                   display_name: 'DigitalGov  Search An Official Website of the U.S. Government Office of Citizen Services & Innovative Technologies',
                   id: 3000,
                   last_month_query_count: 0,
                   name: 'usasearch',
                   nutshell_id: 777,
                   users: double('Users', pluck: [600, 600]),
                   website: 'https://search.digitalgov.gov')
      end

      it 'sends edit_lead request' do
        site.should_receive(:active?).and_return(true)

        expected_nutshell_params = {
          leadId: 777,
          rev: 'REV_IGNORE',
          lead: {
            contacts: [ { id: 600 }],
            customFields: {
              :'Admin Center URL' => 'https://search.usa.gov/sites/3000',
              :'Homepage URL' => 'https://search.digitalgov.gov',
              :'Previous month query count' => 0,
              :'SERP URL' => 'https://search.usa.gov/search?affiliate=usasearch',
              :'Site handle' => 'usasearch',
              :'Super Admin URL' => 'https://search.usa.gov/admin/affiliates?search[id]=3000'
            },
            description: '(usasearch) DigitalGov Search An Official Website of the U.S. Government Office of Citizen...'
          }
        }

        response_body = Hashie::Mash::Rash.new(result: { id: 777 })

        client.should_receive(:post).
          with(:edit_lead, expected_nutshell_params).
          and_return([true, response_body])

        adapter.edit_lead site
      end

      context 'when the site is inactive' do
        it 'append status to the Nutshell params' do
          site.should_receive(:active?).and_return(false)

          expected_nutshell_params = {
            leadId: 777,
            rev: 'REV_IGNORE',
            lead: {
              contacts: [ { id: 600 }],
              customFields: {
                :'Admin Center URL' => 'https://search.usa.gov/sites/3000',
                :'Homepage URL' => 'https://search.digitalgov.gov',
                :'Previous month query count' => 0,
                :'SERP URL' => 'https://search.usa.gov/search?affiliate=usasearch',
                :'Site handle' => 'usasearch',
                :'Super Admin URL' => 'https://search.usa.gov/admin/affiliates?search[id]=3000'
              },
              description: '(usasearch) DigitalGov Search An Official Website of the U.S. Government Office of Citizen...',
              outcome: { id: 3 }
            }
          }

          client.should_receive(:post).
            with(:edit_lead, expected_nutshell_params)

          adapter.edit_lead site
        end
      end
    end
  end

  describe '#new_note' do
    let(:note) { 'This is some note text.' }
    let(:response_body) { Hashie::Mash::Rash.new(result: { id: 777 }) }

    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      context 'for a user' do
        context 'with a nutshell_id' do
          let(:user) { mock_model(User, nutshell_id: 42) }

          it 'sends new_note request' do
            expected_nutshell_params = {
              entity: {
                entityType: 'Contacts',
                id: 42,
              },
              note: 'This is some note text.',
            }

            client.should_receive(:post).
              with(:new_note, expected_nutshell_params).
              and_return([true, response_body])

            adapter.new_note(user, note)
          end
        end

        context 'without a nutshell_id' do
          let(:user) { mock_model(User) }

          it 'does not send new_note request' do
            client.should_not_receive(:post)

            adapter.new_note(user, note)
          end
        end
      end

      context 'for a site' do
        context 'with a nutshell_id' do
          let(:site) { mock_model(Affiliate, nutshell_id: 43) }

          it 'sends new_note request' do
            expected_nutshell_params = {
              entity: {
                entityType: 'Leads',
                id: 43,
              },
              note: 'This is some note text.',
            }

            client.should_receive(:post).
              with(:new_note, expected_nutshell_params).
              and_return([true, response_body])

            adapter.new_note(site, note)
          end
        end

        context 'without a nutshell_id' do
          let(:site) { mock_model(Affiliate) }

          it 'does not send new_note request' do
            client.should_not_receive(:post)

            adapter.new_note(site, note)
          end
        end
      end
    end
  end
end

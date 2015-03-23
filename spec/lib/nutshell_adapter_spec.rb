require 'spec_helper'

describe NutshellAdapter do
  let(:client) { mock(NutshellClient) }
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
      it 'sends NutshellClient#edit_contact' do
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
          'result' => { 'id' => 600,
                       'email' => { '0' => 'mjane@email.gov',
                                    '1' => 'mary.jane@email.gov',
                                    '--primary' => 'mjane@email.gov' },
                       'rev' => '10' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      let(:user) do
        mock_model(User,
                   approval_status: 'approved',
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
              :'Super Admin URL' => 'http://search.usa.gov/admin/users?search[id]=8'
            }
          }
        }
      end

      context 'when contact with matching email does not exists' do
        let(:body_rash) do
          body_hash = {
            'result' => { 'id' => 600 }
          }

          Hashie::Rash.new(body_hash)
        end

        before do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(nil)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_contact, expected_nutshell_params).
            and_return([true, body_rash])

          user_arel = mock('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).
            with(nutshell_id: 600, updated_at: kind_of(Time))

          adapter.new_contact user
        end
      end

      context 'when contact with matching email exists' do
        before do
          user_arel = mock('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).
            with(nutshell_id: 600, updated_at: kind_of(Time))
        end

        it 'calls NutshellAdapter#edit_contact' do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(contact)
          adapter.should_receive(:edit_contact).with(user, contact)

          adapter.new_contact user
        end
      end

      context 'when new_contact returns with error' do
        let(:body_rash) do
          body_hash = {
            'error' => {
              'code' => -32600,
              'message' => 'Missing required parameter',
              'data' => nil
            },
            'result' => nil
          }

          Hashie::Rash.new(body_hash)
        end

        before do
          adapter.should_receive(:get_contact_by_email).
            with('mary.jane@email.gov').
            and_return(nil)
        end

        it 'skips User#update_attributes' do
          client.should_receive(:post).
            with(:new_contact, expected_nutshell_params).
            and_return([false, body_rash])

          user.should_not_receive(:update_attributes)

          adapter.new_contact user
        end
      end
    end
  end

  describe '#edit_contact' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:contact) do
        get_contact_body_hash = {
          'result' => { 'id' => 600,
                       'email' => { '0' => 'mjane@email.gov',
                                    '1' => 'mary.jane@email.gov',
                                    '--primary' => 'mjane@email.gov' },
                       'rev' => '1' }
        }
        Hashie::Rash.new(get_contact_body_hash).result
      end

      let(:user) do
        mock_model(User,
                   approval_status: 'pending_email_verification',
                   contact_name: 'Mary Jane',
                   email: 'mary.jane@email.gov',
                   id: 8,
                   nutshell_id: 600)
      end

      context 'when contact parameter is nil' do
        before do
          user.should_receive(:nutshell_id).and_return(600)
          adapter.should_receive(:get_contact).with(600).and_return(contact)
        end

        it 'sends edit_contact request' do
          expected_nutshell_params = {
            contactId: 600,
            rev: '1',
            contact: {
              customFields: {
                :'Approval status' => 'pending_email_verification',
                :'Super Admin URL' => 'http://search.usa.gov/admin/users?search[id]=8'
              },
              email: { '0' => 'mary.jane@email.gov', '1' => 'mjane@email.gov' },
              name: 'Mary Jane'
            }
          }

          body_rash = Hashie::Rash.new(result: { 'id' => 600 })

          client.should_receive(:post).
            with(:edit_contact, expected_nutshell_params).
            and_return([true, body_rash])

          adapter.edit_contact user
        end
      end

      context 'when contact parameter is present' do
        before { adapter.should_not_receive(:get_contact) }

        it 'sends editContact request' do
          expected_nutshell_params = {
            contactId: 600,
            rev: '1',
            contact: {
              customFields: {
                :'Approval status' => 'pending_email_verification',
                :'Super Admin URL' => 'http://search.usa.gov/admin/users?search[id]=8'
              },
              email: { '0' => 'mary.jane@email.gov', '1' => 'mjane@email.gov' },
              name: 'Mary Jane'
            }
          }

          body_rash = Hashie::Rash.new(result: { 'id' => 600 })

          client.should_receive(:post).
            with(:edit_contact, expected_nutshell_params).
            and_return([true, body_rash])

          adapter.edit_contact user, contact
        end
      end
    end
  end

  describe '#get_contact' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      context 'when result is present' do
        let(:response_body_rash) do
          get_contact_body_hash = {
            'result' => { 'id' => 600,
                         'email' => { '0' => 'mjane@email.gov',
                                      '--primary' => 'mjane@email.gov' },
                         'rev' => '1' }
          }
          Hashie::Rash.new(get_contact_body_hash)
        end

        it 'returns the contact' do
          client.should_receive(:post).
            with(:get_contact, contactId: 600).
            and_return([true, response_body_rash])

          expect(adapter.get_contact(600)).to eq(response_body_rash.result)
        end
      end

      context 'when result is not present' do
        let(:response_rash) do
          get_contact_body_hash = {
            'error' => nil,
            'id' => 'dae8a43ec',
            'jsonrpc' => '2.0',
            'result' => nil
          }

          Hashie::Rash.new(get_contact_body_hash)
        end

        it 'returns nil' do
          client.should_receive(:post).
            with(:get_contact, contactId: 600).
            and_return([true, response_rash])

          expect(adapter.get_contact(600)).to eq(nil)
        end
      end
    end
  end

  describe '#get_contact_by_email' do
    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      context 'when result is present and the email matches' do
        let(:search_contacts_response_rash) do
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

          Hashie::Rash.new response_hash
        end

        let(:get_contact_body_rash) do
          get_contact_body_hash = {
            'result' => { 'id' => 600,
                         'email' => { '0' => 'mjane@email.gov',
                                      '1' => 'mary.jane@email.gov',
                                      '--primary' => 'mjane@email.gov' },
                         'rev' => '1' }
          }
          Hashie::Rash.new get_contact_body_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@email.gov', 1]).
            and_return([true, search_contacts_response_rash])

          adapter.should_receive(:get_contact).
            with(600).
            and_return(get_contact_body_rash.result)
        end

        it 'returns matching contact' do
          expect(adapter.get_contact_by_email('mary.jane@email.gov')).
            to eq(get_contact_body_rash.result)
        end
      end

      context 'when result is not present' do
        let(:search_contacts_response_rash) do
          response_hash = {
            'result' => [],
            'id' => 'apeye',
            'error' => nil,
            'jsonrpc' => '2.0'
          }

          Hashie::Rash.new response_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@email.gov', 1]).
            and_return([true, search_contacts_response_rash])

          adapter.should_not_receive(:get_contact)
        end

        it 'returns matching contact' do
          expect(adapter.get_contact_by_email('mary.jane@email.gov')).to be_nil
        end
      end

      context 'when result is present and the email matches' do
        let(:search_contacts_response_rash) do
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

          Hashie::Rash.new response_hash
        end

        let(:get_contact_body_rash) do
          get_contact_body_hash = {
            'result' => { 'id' => 600,
                          'email' => { '0' => 'mjane@email.gov',
                                       '--primary' => 'mjane@email.gov' },
                          'rev' => '1' }
          }
          Hashie::Rash.new get_contact_body_hash
        end

        before do
          client.should_receive(:post).
            with(:search_contacts, ['mary.jane@email.gov', 1]).
            and_return([true, search_contacts_response_rash])

          adapter.should_receive(:get_contact).
            with(600).
            and_return(get_contact_body_rash.result)
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
              :'Admin Center URL' => 'http://search.usa.gov/sites/3000',
              :'Homepage URL' => 'http://search.digitalgov.gov',
              :'Previous month query count' => 0,
              :'SERP URL' => 'http://search.usa.gov/search?affiliate=usasearch',
              :'Site handle' => 'usasearch',
              :'Status' => 'inactive',
              :'Super Admin URL' => 'http://search.usa.gov/admin/affiliates?search[id]=3000'
            },
            description: 'DigitalGov Search (usasearch)'
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
                   display_name: 'DigitalGov Search',
                   id: 3000,
                   last_month_query_count: 0,
                   name: 'usasearch',
                   status: mock_model(Status, name: 'inactive'),
                   users: mock('Users', pluck: [600]),
                   website: 'http://search.digitalgov.gov')
      end

      context 'when NutshellClient#new_lead is successful' do
        let(:body_rash) do
          body_hash = {
            result: { id: 777 }
          }

          Hashie::Rash.new(body_hash)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_lead, expected_nutshell_params).
            and_return([true, body_rash])

          site.should_receive(:update_attributes).with(nutshell_id: 777)

          adapter.new_lead site
        end
      end

      context 'when NutshellClient#new_lead returns with error' do
        let(:body_rash) do
          body_hash = {
            'error' => {
              'code' => -32600,
              'message' => 'Missing required parameter',
              'data' => nil
            },
            'result' => nil,
          }

          Hashie::Rash.new(body_hash)
        end

        it 'skips Site#update_attributes' do
          client.should_receive(:post).
            with(:new_lead, expected_nutshell_params).
            and_return([false, body_rash])

          site.should_not_receive(:update_attributes)
          adapter.should_not_receive(:push_user)

          adapter.new_lead site
        end
      end
    end
  end

  describe '#edit_lead' do
    fixtures :statuses

    context 'when NutshellClient is enabled' do
      before { NutshellClient.stub(:enabled?).and_return(true) }

      let(:site) do
        mock_model(Affiliate,
                   created_at: Time.parse('2015-02-01 05:00:00 UTC'),
                   display_name: 'DigitalGov Search',
                   id: 3000,
                   last_month_query_count: 0,
                   name: 'usasearch',
                   nutshell_id: 777,
                   users: mock('Users', pluck: [600]),
                   website: 'http://search.digitalgov.gov')
      end

      it 'sends edit_lead request' do
        site.should_receive(:status).and_return(statuses(:'inactive'))

        expected_nutshell_params = {
          leadId: 777,
          rev: 'REV_IGNORE',
          lead: {
            contacts: [ { id: 600 }],
            customFields: {
              :'Admin Center URL' => 'http://search.usa.gov/sites/3000',
              :'Homepage URL' => 'http://search.digitalgov.gov',
              :'Previous month query count' => 0,
              :'SERP URL' => 'http://search.usa.gov/search?affiliate=usasearch',
              :'Site handle' => 'usasearch',
              :'Super Admin URL' => 'http://search.usa.gov/admin/affiliates?search[id]=3000'
            },
            description: 'DigitalGov Search (usasearch)'
          }
        }

        body_rash = Hashie::Rash.new(result: { id: 777, custom_fields: { status: 'Active  -  cfo' } })
        status_arel = mock('status arel')
        Status.should_receive(:where).with(name: 'active - cfo').and_return(status_arel)
        status = mock_model(Status, id: 30)
        status_arel.should_receive(:first_or_create).and_return(status)
        site.should_receive(:update_attributes).with(status_id: 30)

        client.should_receive(:post).
          with(:edit_lead, expected_nutshell_params).
          and_return([true, body_rash])

        adapter.edit_lead site
      end

      context 'when the site status is "inactive - deleted"' do
        it 'append status to the Nutshell params' do
          site.should_receive(:status).and_return(statuses(:'inactive-deleted'))

          expected_nutshell_params = {
            leadId: 777,
            rev: 'REV_IGNORE',
            lead: {
              contacts: [ { id: 600 }],
              customFields: {
                :'Admin Center URL' => 'http://search.usa.gov/sites/3000',
                :'Homepage URL' => 'http://search.digitalgov.gov',
                :'Previous month query count' => 0,
                :'SERP URL' => 'http://search.usa.gov/search?affiliate=usasearch',
                :'Site handle' => 'usasearch',
                :'Status' => 'inactive - deleted',
                :'Super Admin URL' => 'http://search.usa.gov/admin/affiliates?search[id]=3000'
              },
              description: 'DigitalGov Search (usasearch)'
            }
          }

          client.should_receive(:post).
            with(:edit_lead, expected_nutshell_params)

          adapter.edit_lead site
        end
      end
    end
  end
end

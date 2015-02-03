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

      let(:user) do
        mock_model(User,
                   approval_status: 'approved',
                   contact_name: 'Mary Jane',
                   id: 1000,
                   email: 'mary.jane@email.gov')
      end

      let(:expected_nutshell_params) do
        {
          contact: {
            email: %w(mary.jane@email.gov),
            name: 'Mary Jane',
            customFields: {
              :'Approval status' => 'approved',
              :'Super Admin URL' => 'http://search.usa.gov/admin/users?search[id]=1000'
            }
          }
        }
      end

      context 'when new_contact is successful' do
        let(:body_rash) do
          body_hash = {
            result: { id: 8000 }
          }

          Hashie::Rash.new(body_hash)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_contact, expected_nutshell_params).
            and_return([true, body_rash])

          user_arel = mock('User arel')
          User.should_receive(:where).with(id: user.id).and_return(user_arel)
          user_arel.should_receive(:update_all).with(nutshell_id: 8000, updated_at: kind_of(Time))

          adapter.new_contact user
        end
      end

      context 'when new_contact returns with error' do
        let(:body_rash) do
          body_hash = {
            error: {
              code: -32600,
              message: 'Missing required parameter',
              data: nil
            },
            result: nil,
          }

          Hashie::Rash.new(body_hash)
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

      let(:user) do
        mock_model(User,
                   approval_status: 'pending_email_verification',
                   contact_name: 'Mary Jane',
                   email: 'mary.jane@email.gov',
                   id: 1000,
                   nutshell_id: 1000)
      end

      it 'sends edit_contact request' do
        expected_nutshell_params = {
          contactId: 1000,
          rev: 'REV_IGNORE',
          contact: {
            customFields: {
              :'Approval status' => 'pending_email_verification',
              :'Super Admin URL' => 'http://search.usa.gov/admin/users?search[id]=1000'
            },
            email: %w(mary.jane@email.gov),
            name: 'Mary Jane'
          },
        }

        body_rash = Hashie::Rash.new(result: { id: 8000 })

        client.should_receive(:post).
          with(:edit_contact, expected_nutshell_params).
          and_return([true, body_rash])

        adapter.edit_contact user
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
            contacts: [ { id: 888 }],
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
                   nutshell_id: 888)
      end

      let(:site) do
        mock_model(Affiliate,
                   created_at: Time.parse('2015-02-01 05:00:00 UTC'),
                   display_name: 'DigitalGov Search',
                   id: 3000,
                   last_month_query_count: 0,
                   name: 'usasearch',
                   status: mock_model(Status, name: 'inactive'),
                   users: mock('Users', pluck: [888]),
                   website: 'http://search.digitalgov.gov')
      end

      context 'when NutshellClient#new_lead is successful' do
        let(:body_rash) do
          body_hash = {
            result: { id: 999 }
          }

          Hashie::Rash.new(body_hash)
        end

        it 'updates #nutshell_id' do
          client.should_receive(:post).
            with(:new_lead, expected_nutshell_params).
            and_return([true, body_rash])

          site.should_receive(:update_attributes).with(nutshell_id: 999)

          adapter.new_lead site
        end
      end

      context 'when NutshellClient#new_lead returns with error' do
        let(:body_rash) do
          body_hash = {
            error: {
              code: -32600,
              message: 'Missing required parameter',
              data: nil
            },
            result: nil,
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
                   nutshell_id: 8000,
                   users: mock('Users', pluck: [888]),
                   website: 'http://search.digitalgov.gov')
      end

      it 'sends edit_lead request' do
        site.should_receive(:status).and_return(statuses(:'inactive'))

        expected_nutshell_params = {
          leadId: 8000,
          rev: 'REV_IGNORE',
          lead: {
            contacts: [ { id: 888 }],
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

        body_rash = Hashie::Rash.new(result: { id: 8000, custom_fields: { status: 'Active  -  cfo' } })
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
            leadId: 8000,
            rev: 'REV_IGNORE',
            lead: {
              contacts: [ { id: 888 }],
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

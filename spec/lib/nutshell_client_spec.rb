require 'spec_helper'

describe NutshellClient do
  describe '.enabled' do
    it 'should be false in test environment' do
      expect(NutshellClient).to_not be_enabled
    end
  end

  describe '#request_id' do
    specify { expect(NutshellClient.new.request_id.length).to be(9) }
  end

  describe '#post' do
    let(:client) { NutshellClient.new }

    before { client.stub(:request_id) { 'f6f91f185' } }

    context 'when #post was successful' do
      let(:success_params) do
        { id: 'f6f91f185',
          jsonrpc: '2.0',
          method: 'editLead',
          params: {
            lead: {
              createdTime: '2015-02-01T05:00:00+00:00',
              customFields: { :'Site handle' => 'usasearch', :Status => 'inactive' },
              description: 'DigitalGov Search (usasearch)'
            }
          }
        }
      end

      let(:lead_params) do
        {
          lead: {
            createdTime: '2015-02-01T05:00:00+00:00',
            customFields: {
              :'Site handle' => 'usasearch',
              :'Status' => 'inactive'
            },
            description: 'DigitalGov Search (usasearch)'
          }
        }
      end

      let(:success_result) do
        Rails.root.join('spec/fixtures/json/nutshell/edit_lead_response.json').read
      end

      before do
        stub_request(:post, "https://app01.nutshell.com/api/v1/json").
          with( body: success_params ).to_return( status: 200, body: success_result)
      end

      it 'returns with result' do
        is_success, rash_body = client.post :edit_lead, lead_params
        expect(is_success).to be_true
        expect(rash_body.result.id).to eq(2101)
      end
    end

    context 'when #post failed' do
      let(:error_params) do
        { id: 'f6f91f185',
          jsonrpc: '2.0',
          method: 'editLead',
          params: {
            lead: {
              createdTime: '2015-02-01T05:00:00+00:00',
              customFields: { :'Bad field' => 'usasearch' },
              description: 'DigitalGov Search (usasearch)'
            }
          }
        }
      end

      let(:error_result) do
        Rails.root.join('spec/fixtures/json/nutshell/edit_lead_response_with_error.json').read
      end

      before do
        stub_request(:post, "https://app01.nutshell.com/api/v1/json").
          with( body: error_params ).to_return( status: 400, body: error_result )
      end

      let(:lead_params) do
        {
          lead: {
            createdTime: '2015-02-01T05:00:00+00:00',
            customFields: { :'Bad field' => 'usasearch' },
            description: 'DigitalGov Search (usasearch)'
          }
        }
      end

      it 'returns with error' do
        is_success, rash_body = client.post :edit_lead, lead_params
        expect(is_success).to be_false
        expect(rash_body.error.message).to eq(" Field 'Bad field' is not a custom field")
      end
    end
  end
end

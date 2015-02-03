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

      it 'returns with result' do
        is_success, rash_body = client.post :edit_lead, lead_params
        expect(is_success).to be_true
        expect(rash_body.result.id).to eq(2101)
      end
    end

    context 'when #post failed' do
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

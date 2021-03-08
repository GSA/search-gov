require 'spec_helper'

describe Api::V2::AgenciesController do

  describe '#search' do
    context 'when results are available' do
      before do
        @agency = Agency.create!(name: 'National Park Service', abbreviation: 'NPS')
        AgencyOrganizationCode.create!(organization_code: 'NP01', agency: @agency)
        AgencyOrganizationCode.create!(organization_code: 'NP00', agency: @agency)
      end

      it 'should return valid JSON with the organization codes array in alpha order' do
        get :search, params: { query: 'the nps' }, format: 'json'
        expect(response).to be_success
        expect(response.body).to eq({name: @agency.name, abbreviation: @agency.abbreviation,
                                 organization_codes: @agency.agency_organization_codes.collect(&:organization_code).sort }.to_json)
      end
    end

    context 'when search returns nil or raises an exception' do
      it 'should return error string' do
        get :search, params: { query: 'error' }, format: 'json'
        expect(response).not_to be_success
        expect(response.body).to match(/No matching agency could be found./)
      end
    end
  end

end

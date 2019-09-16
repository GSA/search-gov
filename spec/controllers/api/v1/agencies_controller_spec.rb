require 'spec_helper'

describe Api::V1::AgenciesController do

  describe "#search" do

    context 'when results are available' do
      before do
        @agency = Agency.
          create!(name: 'National Park Service', abbreviation: 'NPS')
        AgencyOrganizationCode.create!(organization_code: 'NP00', agency: @agency)
        AgencyOrganizationCode.create!(organization_code: 'NP01', agency: @agency)
      end

      it 'should return valid JSON with just the first organization code' do
        get :search,
            params: {
              query: 'the nps'
            },
            format: 'json'
        expect(response).to be_success
        expect(response.body).to eq({name: @agency.name, abbreviation: @agency.abbreviation,
                                 organization_code: @agency.agency_organization_codes.first.organization_code }.to_json)
      end
    end

    context 'when search returns nil or raises an exception' do
      it 'should return error string' do
        get :search,
            params: {
              query: 'error',
              format: 'json'
            }
        expect(response).not_to be_success
        expect(response.body).to match(/No matching agency could be found./)
      end
    end
  end
end

require 'spec_helper'

describe Agency do
  before do
    Agency.destroy_all
    @valid_attributes = {
      :name => '  Internal Revenue   Service  ',
      :abbreviation => 'IRS'
    }
  end

  context "when creating a new agency" do
    before do
      Agency.create!(@valid_attributes)
    end

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to have_many :affiliates }
  end

  describe "#save" do
    context "when saving with valid attributes" do
      before do
        @agency = Agency.create!(@valid_attributes)
        AgencyOrganizationCode.create!(organization_code: " XX00 ", agency: @agency)
      end

      it 'squishes name and organization_code' do
        expect(@agency.name).to eq 'Internal Revenue Service'
        expect(@agency.agency_organization_codes.first.organization_code).to eq 'XX00'
      end

      it "should create a bunch of agency queries on save" do
        expect(@agency.agency_queries).not_to be_empty
        expect(@agency.agency_queries.find_by_phrase("irs")).not_to be_nil
        expect(@agency.agency_queries.find_by_phrase("the internal revenue service")).not_to be_nil
      end
    end

    context 'when there is a FederalRegisterAgency' do
      fixtures :federal_register_agencies

      it 'loads documents' do
        fr_noaa = federal_register_agencies(:fr_noaa)
        expect(fr_noaa).to receive(:load_documents)

        Agency.create!(federal_register_agency: fr_noaa, name: 'National Oceanic and Atmospheric Administration')
      end
    end
  end

  describe '#friendly_name' do
    context 'when the agency belongs to a federal register agency' do
      fixtures :federal_register_agencies
      let(:agency) { Agency.create!(@valid_attributes.merge(federal_register_agency: federal_register_agencies(:fr_irs))) }
      before do
        AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
      end

      it 'returns name with Federal Register Agency name' do
        expect(agency.friendly_name).to match 'Internal Revenue Service FRA: Internal Revenue Service'
        expect(agency.friendly_name).to match /JOBS: XX00$/
      end
    end

    context 'when the agency does not belong to a federal register agency' do
      let(:agency) { Agency.create!(@valid_attributes) }

      before do
        AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
      end

      it 'returns name with Federal Register Agency name' do
        expect(agency.friendly_name).to eq 'Internal Revenue Service JOBS: XX00'
      end
    end
  end
end

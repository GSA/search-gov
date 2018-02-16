require 'spec_helper'

describe FederalRegisterAgencyData do
  fixtures :agencies, :federal_register_agencies

  describe '.import' do
    let(:fr_doc) { federal_register_agencies(:fr_doc) }
    let(:fr_irs) { federal_register_agencies(:fr_irs) }
    let(:fr_noaa) { federal_register_agencies(:fr_noaa) }

    before do
      mock_doc = double(FederalRegister::Agency,
                      attributes: { 'id' => fr_doc.id,
                                    'name' => 'Commerce Department',
                                    'parent_id' => nil,
                                    'short_name' => 'DOC' })
      mock_irs = double(FederalRegister::Agency,
                      attributes: { 'id' => fr_irs.id,
                                    'name' => 'Internal Revenue Service updated',
                                    'parent_id' => nil,
                                    'short_name' => 'IRS' })
      mock_noaa = double(FederalRegister::Agency,
                       attributes: { 'id' => fr_noaa.id,
                                     'name' => 'National Oceanic and Atmospheric Administration',
                                     'parent_id' => 54,
                                     'short_name' => 'NOAA' })

      mock_unknown_agency = double(FederalRegister::Agency,
                                 attributes: { 'id' => 200,
                                               'name' => ' Some  unknown  agency ',
                                               'parent_id' => nil,
                                               'short_name' => ' UNKNOWN ' })
      expect(FederalRegister::Agency).to receive(:all).and_return([mock_doc, mock_irs, mock_noaa, mock_unknown_agency])
    end

    it 'updates existing record with matching id' do
      original_fr_agency = FederalRegisterAgency.find(fr_irs.id)
      expect(original_fr_agency.name).to eq('Internal Revenue Service')

      FederalRegisterAgencyData.import

      expect(FederalRegisterAgency.count).to eq(4)

      update_fr_agency = FederalRegisterAgency.find(fr_irs.id)
      expect(original_fr_agency.created_at).to eq(update_fr_agency.created_at)
      expect(update_fr_agency.name).to eq('Internal Revenue Service')

      fr_agency_with_updated_name = FederalRegisterAgency.find(fr_doc.id)
      expect(fr_agency_with_updated_name.name).to eq agencies(:doc).name

      fr_agency_with_parent_id = FederalRegisterAgency.find(fr_noaa.id)
      expect(fr_agency_with_parent_id.parent_id).to eq 54

      fr_unknown_agency = FederalRegisterAgency.find 200
      expect(fr_unknown_agency.name).to eq 'Some unknown agency'
      expect(fr_unknown_agency.short_name).to eq 'UNKNOWN'
    end

    it 'destroys obsolete FederalRegisterAgency' do
      FederalRegisterAgency.create!(id: 100, name: 'Bogus')

      FederalRegisterAgencyData.import

      expect(FederalRegisterAgency.find_by_id(100)).to be_nil
      expect(FederalRegisterAgency.count).to eq(4)
    end
  end
end

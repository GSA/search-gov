require 'spec_helper'

describe FederalRegisterAgencyData do
  fixtures :federal_register_agencies

  describe '.import' do
    let(:fr_irs) { federal_register_agencies(:fr_irs) }

    before do
      mock_gsa = mock(FederalRegister::Agency, id: 210,
                    name: 'General Services Administration',
                    short_name: 'GSA')
      mock_irs = mock(FederalRegister::Agency, id: fr_irs.id,
                    name: 'Internal Revenue Service updated',
                    short_name: 'IRS')
      FederalRegister::Agency.should_receive(:all).and_return([mock_gsa, mock_irs])
    end

    it 'updates existing record with matching id' do
      original_fr_agency = FederalRegisterAgency.find(fr_irs.id)
      original_fr_agency.name.should == 'Internal Revenue Service'

      FederalRegisterAgencyData.import

      FederalRegisterAgency.count.should == 2
      fr_gsa = FederalRegisterAgency.find(210)
      fr_gsa.name.should == 'General Services Administration'
      fr_gsa.short_name.should == 'GSA'

      update_fr_agency = FederalRegisterAgency.find(fr_irs.id)
      original_fr_agency.created_at.should == update_fr_agency.created_at
      update_fr_agency.name.should == 'Internal Revenue Service updated'
    end

    it 'destroys obsolete FederalRegisterAgency' do
      FederalRegisterAgency.create!(id: 100, name: 'Bogus')

      FederalRegisterAgencyData.import

      FederalRegisterAgency.find_by_id(100).should be_nil
      FederalRegisterAgency.count.should == 2
    end
  end
end

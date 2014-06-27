require 'spec_helper'

describe FederalRegisterAgency do
  fixtures :federal_register_agencies, :agencies

  context 'when deleting an existing FederalRegisterAgency that is mapped to Agency' do
    it 'does not modify agencies.federal_register_agency_id' do
      fr_irs = federal_register_agencies(:fr_irs)
      irs = agencies(:irs)
      fr_irs.agencies.to_a.should == [irs]

      fr_irs.destroy

      irs.federal_register_agency_id.should == 254
    end
  end
end

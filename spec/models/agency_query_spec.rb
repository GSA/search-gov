require 'spec_helper'

describe AgencyQuery do
  fixtures :agencies

  before do
    @valid_attributes = {
      :phrase => 'irs',
      :agency => agencies(:irs)
    }
    AgencyQuery.create!(@valid_attributes)
  end

  it { should validate_presence_of :phrase }
  it { should validate_uniqueness_of :phrase }
end

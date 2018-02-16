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

  it { is_expected.to validate_presence_of :phrase }
  it { is_expected.to validate_uniqueness_of(:phrase).case_insensitive }
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AgencyQuery do
  fixtures :agencies
  
  before do
    @valid_attributes = {
      :phrase => 'irs',
      :agency => agencies(:irs)
    }
    AgencyQuery.create!(@valid_attributes)
  end
  
  should_validate_presence_of :phrase
  should_validate_uniqueness_of :phrase
end
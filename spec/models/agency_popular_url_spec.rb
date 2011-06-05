require 'spec/spec_helper'

describe AgencyPopularUrl do

  it { should validate_presence_of :agency_id }
  it { should validate_presence_of :url }
  it { should validate_presence_of :title }

end

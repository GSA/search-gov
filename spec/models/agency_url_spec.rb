require 'spec/spec_helper'

describe AgencyUrl do
  it { should validate_presence_of :agency_id }
  it { should validate_presence_of :url }
  it { should validate_presence_of :locale }

end

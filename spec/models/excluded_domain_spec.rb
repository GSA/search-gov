require 'spec/spec_helper'

describe ExcludedDomain do
  @valid_attributes = {
    :domain => 'windstream.net'
  }
  
  it { should validate_presence_of :domain }
end

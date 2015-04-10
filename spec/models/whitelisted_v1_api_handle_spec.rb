require 'spec_helper'

describe WhitelistedV1ApiHandle do
  it { should validate_presence_of :handle }
  it { should validate_uniqueness_of :handle }
end

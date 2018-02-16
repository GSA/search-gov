require 'spec_helper'

describe WhitelistedV1ApiHandle do
  it { is_expected.to validate_presence_of :handle }
  it { is_expected.to validate_uniqueness_of(:handle).case_insensitive }
end

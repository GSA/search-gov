require 'spec_helper'

describe Hint do
  it { is_expected.to validate_presence_of :name }
end

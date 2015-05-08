require 'spec_helper'

describe Hint do
  it { should validate_presence_of :name }
end

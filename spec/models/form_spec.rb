require 'spec_helper'

describe Form do
  it { should validate_presence_of :agency }
  it { should validate_presence_of :number }
  it { should validate_presence_of :url }
end

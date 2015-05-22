require 'spec_helper'

describe Language do
  fixtures :languages, :affiliates
  it { should have_many(:affiliates) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).case_insensitive }
  it { should validate_presence_of(:name) }
end

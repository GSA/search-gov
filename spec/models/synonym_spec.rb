require 'spec/spec_helper'

describe Synonym do
  before do
    @valid_attributes = {
      :phrase => 'gsa',
      :alias => 'general services administration',
      :source => 'bing'
    }
    Synonym.create!(@valid_attributes)
  end
  
  it { should validate_presence_of :phrase }
  it { should validate_presence_of :alias }
  it { should validate_uniqueness_of(:alias).scoped_to(:phrase) }
  
  it "should default source to 'admin'" do
    synonym = Synonym.create!(:phrase => 'cia', :alias => 'central intelligence agency')
    synonym.source.should == 'admin'
  end
end

require 'spec_helper'

describe TwitterList do
  it { should validate_numericality_of(:id).only_integer }
  it 'should not allow id = 0' do
    TwitterList.new(id: 0).should_not be_valid
  end
  it { should have_and_belong_to_many :twitter_profiles }
end
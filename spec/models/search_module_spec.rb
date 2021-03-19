require 'spec_helper'

describe SearchModule do
  fixtures :search_modules

  before(:each) do
    @valid_attributes = {
      display_name: 'Some name',
      tag: 'IMATAG'
    }
  end

  describe 'Creating new instance' do
    it { is_expected.to validate_presence_of :tag }
    it { is_expected.to validate_presence_of :display_name }
    it { is_expected.to validate_uniqueness_of :tag }

    it 'should create a new instance given valid attributes' do
      described_class.create!(@valid_attributes)
    end
  end
end

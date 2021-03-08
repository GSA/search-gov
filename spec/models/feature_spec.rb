require 'spec_helper'

describe Feature do
  fixtures :features

  let(:valid_attributes) { {:display_name => 'Awesome Feature', :internal_name => 'awesome_feature'} }

  describe '#label' do
    it 'should return the display name' do
      f = features(:disco)
      expect(f.label).to eq(f.display_name)
    end
  end

  describe 'creating a new Feature' do
    it { is_expected.to validate_presence_of :internal_name }
    it { is_expected.to validate_presence_of :display_name }
    it { is_expected.to validate_uniqueness_of :internal_name }
    it { is_expected.to validate_uniqueness_of :display_name }
    it { is_expected.to have_many(:affiliates) }
    it { is_expected.to have_many(:affiliate_feature_addition).dependent(:destroy) }
    it 'should create a new instance given valid attributes' do
      Feature.create!(valid_attributes)
    end
  end
end

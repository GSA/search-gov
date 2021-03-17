require 'spec_helper'

describe I14yMembership do
  fixtures :i14y_drawers, :affiliates, :i14y_memberships

  it { is_expected.to belong_to(:affiliate), inverse_of: :i14y_memberships }
  it { is_expected.to belong_to(:i14y_drawer), inverse_of: :i14y_memberships }

  describe '#label' do
    it 'should show the affiliate name and i14y drawer handle' do
      expect(i14y_memberships(:one).label).to eq('noaa.gov:one')
    end
  end

  describe '#dup' do
    subject(:original_instance) { i14y_memberships(:one) }
    include_examples 'site dupable'
  end
end

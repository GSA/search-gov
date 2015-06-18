require 'spec_helper'

describe I14yMembership do
  fixtures :i14y_drawers, :affiliates, :i14y_memberships

  it { should belong_to(:affiliate) }
  it { should belong_to(:i14y_drawer) }

  describe "#label" do
    it 'should show the affiliate name and i14y drawer handle' do
      i14y_memberships(:one).label.should == 'noaa.gov:one'
    end
  end

  describe '#dup' do
    subject(:original_instance) { i14y_memberships(:one) }
    include_examples 'site dupable'
  end
end

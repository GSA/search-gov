require 'spec_helper'

describe SitesHelper do
  describe "#daily_snapshot_toggle(membership)" do
    context 'when membership is nil' do
      it 'should return nil' do
        helper.daily_snapshot_toggle(nil).should be_nil
      end
    end
  end
end
require 'spec_helper'

describe SiteDestroyer, "#perform(site_id)" do

  let(:affiliate) { mock_model(Affiliate, name: 'goner', id: 1234)}

  before do
    Affiliate.stub(:find).with(1234).and_return affiliate
  end

  it "should delete/destroy all associated information with that site" do
    affiliate.should_receive(:destroy)
    SiteDestroyer.perform(affiliate.id)
  end

end
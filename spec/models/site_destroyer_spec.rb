require 'spec_helper'

describe SiteDestroyer, "#perform(site_id)" do
  it_behaves_like 'a ResqueJobStats job'

  context 'when site is located' do
    let(:affiliate) { mock_model(Affiliate, name: 'goner', id: 1234) }

    before do
      Affiliate.stub(:find).with(1234).and_return affiliate
    end

    it "should delete/destroy all associated information with that site" do
      affiliate.should_receive(:destroy)
      SiteDestroyer.perform(affiliate.id)
    end
  end

  context 'when it cannot locate the site' do
    it 'should log the warning' do
      Rails.logger.should_receive(:warn)
      SiteDestroyer.perform -1
    end
  end

end

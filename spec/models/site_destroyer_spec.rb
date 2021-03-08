require 'spec_helper'

describe SiteDestroyer, '#perform(site_id)' do
  it_behaves_like 'a ResqueJobStats job'

  context 'when site is located' do
    let(:affiliate) { mock_model(Affiliate, name: 'goner', id: 1234) }

    before do
      allow(Affiliate).to receive(:find).with(1234).and_return affiliate
    end

    it 'should delete/destroy all associated information with that site' do
      expect(affiliate).to receive(:destroy)
      described_class.perform(affiliate.id)
    end
  end

  context 'when it cannot locate the site' do
    it 'should log the warning' do
      expect(Rails.logger).to receive(:warn)
      described_class.perform -1
    end
  end

end

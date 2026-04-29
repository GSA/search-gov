# frozen_string_literal: true

describe NavigableNameUpdater do
  context 'no locale exceptions array passed in' do
    let(:navigable_name_updater) { described_class.new }

    before do
      affiliates(:basic_affiliate).update_attribute(:locale, 'kl')
    end

    it 'updates all image search labels except for English/Spanish sites' do
      expect { navigable_name_updater.update }.to change { ImageSearchLabel.where(name: 'Assit').count }.from(0).to(1)
    end
  end
end

require 'spec_helper'

describe NavigableNameUpdater do
  fixtures :affiliates, :languages, :rss_feeds, :image_search_labels

  context 'no locale exceptions array passed in' do
    let(:navigable_name_updater) { described_class.new }

    before do
      affiliates(:basic_affiliate).update_attribute(:locale, 'kl')
    end

    it 'updates all image search labels except for English/Spanish sites' do
      expect { navigable_name_updater.update }.to change { ImageSearchLabel.where(name: 'Assit').count }.from(0).to(1)
    end

    it 'updates all video search labels except for English/Spanish sites' do
      expect { navigable_name_updater.update }.to change { RssFeed.where(name: 'Test Entry').count }.from(0).to(1)
    end
  end
end
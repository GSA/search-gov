# frozen_string_literal: true

describe NavigableNameUpdater do
  context 'no locale exceptions array passed in' do
    let(:navigable_name_updater) { described_class.new }
    let(:video_feed) { rss_feeds(:managed_video) }

    before do
      affiliates(:basic_affiliate).update_attribute(:locale, 'kl')
    end

    it 'updates all image search labels except for English/Spanish sites' do
      expect { navigable_name_updater.update }.to change { ImageSearchLabel.where(name: 'Assit').count }.from(0).to(1)
    end

    context 'when a video feed label is outdated' do
      before { video_feed.update!(name: 'outdated') }

      it 'updates all video search labels except for English/Spanish sites' do
        expect { navigable_name_updater.update }.
          to change { video_feed.reload.name }.from('outdated').to('Videos')
      end
    end
  end
end

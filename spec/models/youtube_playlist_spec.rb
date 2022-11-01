# frozen_string_literal: true

describe YoutubePlaylist do
  let(:youtube_playlist) { described_class.new }

  describe 'schema' do
    it { is_expected.to have_db_column(:safe_news_item_ids).of_type(:json) }
  end

  it { is_expected.to belong_to :youtube_profile }
  it { is_expected.to validate_uniqueness_of(:playlist_id).
                scoped_to(:youtube_profile_id) }

  describe '.news_item_ids' do
    subject(:news_item_ids) { youtube_playlist.news_item_ids }

    it { is_expected.to be_an Array }

    context 'when the playlist has news items' do
      let(:youtube_playlist) { described_class.new(news_item_ids: [1, 2]) }

      it { is_expected.to eq [1, 2] }
    end
  end
end

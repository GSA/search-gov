# frozen_string_literal: true

describe YoutubePlaylist do
  subject(:youtube_playlist) { described_class.new }

  describe 'schema' do
    it { is_expected.to have_db_column(:playlist_id).of_type(:string) }
    it { is_expected.to have_db_column(:youtube_profile_id).of_type(:integer) }
    it { is_expected.to have_db_column(:news_item_ids).of_type(:json) }
    # temporary backup column - will be removed per SRCH-3465
    it { is_expected.to have_db_column(:unsafe_news_item_ids).of_type(:text) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :youtube_profile }
  end

  describe 'validations' do
    it do
      create(:youtube_playlist)
      is_expected.to validate_uniqueness_of(:playlist_id)
        .scoped_to(:youtube_profile_id)
        .case_insensitive
    end
  end

  describe '.news_item_ids' do
    subject(:news_item_ids) { youtube_playlist.news_item_ids }

    it { is_expected.to be_an Array }

    context 'when the playlist has news items' do
      let(:youtube_playlist) { described_class.new(news_item_ids: [1, 2]) }

      it { is_expected.to eq [1, 2] }
    end

    context 'when news_item_ids is not an array' do
      let(:news_item_ids) { 'not an array' }

      it 'raises an error' do
        expect do
          youtube_playlist.update!(news_item_ids: news_item_ids)
        end.to raise_error(ActiveRecord::SerializationTypeMismatch)
      end
    end
  end
end

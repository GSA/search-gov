class YoutubePlaylist < ApplicationRecord
  belongs_to :youtube_profile
  serialize :news_item_ids, Array
  validates_uniqueness_of :playlist_id, scope: :youtube_profile_id
end

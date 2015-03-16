class YoutubePlaylist < ActiveRecord::Base
  attr_accessible :etag, :news_item_ids, :playlist_id
  belongs_to :youtube_profile
  serialize :news_item_ids, Array
  validates_uniqueness_of :playlist_id, scope: :youtube_profile_id
end

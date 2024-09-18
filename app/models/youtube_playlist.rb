# frozen_string_literal: true

class YoutubePlaylist < ApplicationRecord
  belongs_to :youtube_profile
  validates :playlist_id, uniqueness: { scope: :youtube_profile_id, case_sensitive: true }

  def news_item_ids
    super || []
  end

  def news_item_ids=(value)
    raise ActiveRecord::SerializationTypeMismatch, 'news_item_ids must be an Array' unless value.is_a?(Array)

    super(value)
  end
end

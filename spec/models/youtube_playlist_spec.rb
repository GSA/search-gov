require 'spec_helper'

describe YoutubePlaylist do
  it { should belong_to :youtube_profile }
  it { should validate_uniqueness_of(:playlist_id).
                scoped_to(:youtube_profile_id) }
end

require 'spec_helper'

describe YoutubePlaylist do
  it { is_expected.to belong_to :youtube_profile }
  it { is_expected.to validate_uniqueness_of(:playlist_id).
                scoped_to(:youtube_profile_id) }
end

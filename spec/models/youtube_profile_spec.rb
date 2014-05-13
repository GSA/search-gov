require 'spec_helper'

describe YoutubeProfile do
  fixtures :youtube_profiles
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { should validate_presence_of :username }
  it { should have_one(:rss_feed).dependent :destroy }
  it { should have_and_belong_to_many :affiliates }
  it { should validate_uniqueness_of(:username).
                  with_message(/has already been added/).case_insensitive }
end

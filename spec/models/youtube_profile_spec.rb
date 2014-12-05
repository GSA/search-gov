require 'spec_helper'

describe YoutubeProfile do
  fixtures :youtube_profiles
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { should validate_presence_of :username }
  it { should have_one(:rss_feed).dependent :destroy }
  it { should have_and_belong_to_many :affiliates }
  it { should validate_uniqueness_of(:username).
                  with_message(/has already been added/).case_insensitive }

  describe ".extract_profile_name(url)" do
    context 'when url looks like what we expect' do
      let(:url) { "https://www.youtube.com/user/HQAFSFC" }

      it 'should extract the profile name' do
        YoutubeProfile.extract_profile_name(url).should eq("HQAFSFC")
      end
    end

    context 'when url has params' do
      let(:url) { "https://www.youtube.com/user/HQAFSFC?view=0" }

      it 'should ignore the params' do
        YoutubeProfile.extract_profile_name(url).should eq("HQAFSFC")
      end
    end
  end
end

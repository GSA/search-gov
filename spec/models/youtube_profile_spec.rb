require 'spec_helper'

describe YoutubeProfile do
  let(:valid_attributes) { { username: 'USAgency' }.freeze }

  it { should validate_presence_of :username }
  it { should have_one(:rss_feed).dependent :destroy }
  it { should have_and_belong_to_many :affiliates }

  it 'should validate username' do
    HttpConnection.should_receive(:get).
        with('http://gdata.youtube.com/feeds/api/users/someinvaliduser').
        and_raise(OpenURI::HTTPError.new('404 Not Found', StringIO.new))

    profile = YoutubeProfile.new(username: 'someinvaliduser')
    profile.should_not be_valid
    profile.errors[:username].should include('is invalid')
  end

  it 'should handle blank xml when fetching xml profile' do
    HttpConnection.should_receive(:get).
        with('http://gdata.youtube.com/feeds/api/users/accountclosed').
        and_return(StringIO.new(''))
    mock_doc = mock('doc')
    Nokogiri.should_receive(:XML).and_return(mock_doc)
    mock_doc.should_receive(:xpath).and_return([])

    profile = YoutubeProfile.new(username: 'accountclosed')
    profile.should_not be_valid
  end

  context '#create' do
    it 'should normalize username' do
      HttpConnection.stub(:get) do |arg|
        case arg
        when YoutubeProfile.xml_profile_url('usagency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube_user.xml')
        when YoutubeProfile.youtube_url('usagency')
          File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml')
        end
      end

      YoutubeProfile.create!(valid_attributes)
      YoutubeProfile.new(valid_attributes.merge(username: 'usagency')).should_not be_valid
    end
  end
end

require 'spec_helper'

describe TwitterData do
  let(:client) { mock('Twitter Client') }

  describe '#import_profile' do
    let(:user) do
      mock(Twitter::User, id: 100,
           screen_name: 'usasearchdev',
           name: 'USASearch Dev',
           profile_image_url_https: 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
    end

    it 'should create profile' do
      TwitterData.import_profile(user)
      TwitterProfile.find_by_twitter_id(user.id).should be_present
    end
  end

  describe '#import_tweet' do
    it 'should ignore tweets older than 3 days ago' do
      status = mock(Twitter::Tweet,
                    id: 100,
                    retweet?: false,
                    text: 'hello from Twitter',
                    urls: [],
                    media: [])

      tweet = mock_model(Tweet, new_record?: true)

      status.should_receive(:created_at).and_return(100.hours.ago)
      Tweet.stub_chain(:where, :first_or_initialize) { tweet }
      tweet.should_not_receive(:update_attributes!)

      TwitterData.import_tweet(status)
    end
  end

  describe '#refresh_lists' do
    it 'should import twitter profile lists' do
      profile = mock_model(TwitterProfile)
      TwitterProfile.stub_chain(:show_lists_enabled, :limit).and_return([profile])
      profile.should_receive(:touch)
      TwitterData.should_receive(:import_twitter_profile_lists).with(profile)
      TwitterData.refresh_lists
    end
  end

  describe '#import_twitter_profile_lists' do
    let(:profile) { mock_model(TwitterProfile, twitter_id: 100, twitter_lists: []) }
    let(:list) { mock(Twitter::List, id: 8) }
    let(:ar_list) { mock_model(TwitterList) }

    before do
      TwitterClient.should_receive(:instance).and_return(client)
      client.should_receive(:lists).with(100).and_return([list])
      TwitterData.should_receive(:import_list).with(8).and_return(ar_list)
    end

    context 'when the profile twitter lists does not include the imported list' do
      it 'should append the imported lists to the profile' do
        profile.stub_chain(:twitter_lists, :exists?).with(ar_list.id).and_return(false)
        profile.twitter_lists.should_receive(:<<).with(ar_list)
        TwitterData.import_twitter_profile_lists(profile)
      end
    end

    context 'when the profile twitter lists include the imported list' do
      it 'should not append the imported lists to the profile' do
        profile.stub_chain(:twitter_lists, :exists?).with(ar_list.id).and_return(true)
        profile.twitter_lists.should_not_receive(:<<).with(ar_list)
        TwitterData.import_twitter_profile_lists(profile)
      end
    end
  end

  describe '#import_list' do
    it 'should create the list' do
      member_ids = [2, 3, 5, 7, 11].freeze
      TwitterData.should_receive(:get_list_member_ids).with(100).and_return(member_ids)
      ar_list = mock_model(TwitterList)
      TwitterList.stub_chain(:where, :first_or_initialize).and_return(ar_list)
      ar_list.should_receive(:update_attributes!).with(member_ids: member_ids)
      TwitterData.import_list(100)
    end
  end

  describe '#get_list_member_ids' do
    it 'should return member ids' do
      member_ids = [[17, 13, 11], [5, 3, 2], []].freeze
      cursor = mock(Twitter::Cursor)

      TwitterClient.stub(:instance) { client }
      client.should_receive(:list_members).with(100, cursor: -1).and_return(cursor)
      client.should_receive(:list_members).with(100, cursor: 5).and_return(cursor)

      cursor_attrs = mock('cursor attributes')
      cursor.stub(:attrs).and_return(cursor_attrs)

      cursor_attrs.stub_chain(:[], :map).and_return(member_ids[0], member_ids[1])
      cursor_attrs.should_receive(:[]).with(:next_cursor).and_return(5, 0)
      TwitterData.get_list_member_ids(100).should == member_ids.flatten
    end
  end

  describe '#refresh_lists_statuses' do
    context 'when there is a list to refresh' do
      it 'should import list members and tweets' do
        list = mock_model(TwitterList)
        TwitterList.stub_chain(:active, :statuses_updated_before).and_return([list])
        list.should_receive(:update_column).with(:statuses_updated_at, a_kind_of(Time))
        TwitterData.should_receive(:import_list_members_and_tweets).with(list)
        TwitterData.refresh_lists_statuses
      end
    end
  end

  describe '#import_list_member_and_tweets' do
    let(:list) { mock_model(TwitterList, last_status_id: 100) }
    let(:statuses) { mock('statuses', empty?: false) }
    let(:status) { mock('status', user: mock('user')) }

    before { TwitterList.stub(:find_by_id).and_return(list) }

    it 'should process all tweets' do
      TwitterClient.should_receive(:instance).twice.and_return(client)

      client.should_receive(:list_timeline).
          with(list.id,
               { since_id: list.last_status_id, count: TwitterData::LIST_TIMELINE_PER_PAGE }).
          and_return(statuses)

      statuses.should_receive(:each).and_yield(status)
      TwitterData.should_receive(:import_tweet).with(status)

      statuses.stub_chain(:first, :id).and_return(1000)
      statuses.stub_chain(:last, :id).and_return(500)

      statuses.should_receive(:length).and_return(TwitterData::LIST_TIMELINE_PER_PAGE)
      client.should_receive(:list_timeline).
          with(list.id,
               { since_id: list.last_status_id, max_id: 500, count: TwitterData::LIST_TIMELINE_PER_PAGE }).
          and_return([])
      list.should_receive(:update_column).with(:last_status_id, 1000)

      TwitterData.import_list_members_and_tweets(list)
    end
  end

  describe '#get_list_statuses' do
    it 'should return an empty array if the list is not found' do
      TwitterClient.should_receive(:instance).and_return(client)
      client.should_receive(:list_timeline).and_raise(Twitter::Error::NotFound)
      TwitterData.get_list_statuses(1, {}).should be_empty
    end
  end
end

require 'spec_helper'

describe TwitterData do
  let(:client) { double('Twitter Client') }

  describe '#import_profile' do
    let(:user) do
      double(Twitter::User, id: 100,
           screen_name: 'usasearchdev',
           name: 'USASearch Dev',
           profile_image_url_https: 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
    end

    it 'should create profile' do
      TwitterData.import_profile(user)
      expect(TwitterProfile.find_by_twitter_id(user.id)).to be_present
    end
  end

  describe '#import_tweet' do
    it 'should ignore tweets older than 3 days ago' do
      status = double(Twitter::Tweet,
                    id: 100,
                    retweet?: false,
                    text: 'hello from Twitter',
                    urls: [],
                    media: [])

      tweet = mock_model(Tweet, new_record?: true)

      expect(status).to receive(:created_at).and_return(100.hours.ago)
      allow(Tweet).to receive_message_chain(:where, :first_or_initialize) { tweet }
      expect(tweet).not_to receive(:update_attributes!)

      TwitterData.import_tweet(status)
    end
  end

  describe '#refresh_lists' do
    it 'should import twitter profile lists' do
      profile = mock_model(TwitterProfile)
      allow(TwitterProfile).to receive_message_chain(:show_lists_enabled, :limit).and_return([profile])
      expect(profile).to receive(:touch)
      expect(TwitterData).to receive(:import_twitter_profile_lists).with(profile)
      TwitterData.refresh_lists
    end
  end

  describe '#import_twitter_profile_lists' do
    let(:profile) { mock_model(TwitterProfile, twitter_id: 100, twitter_lists: []) }
    let(:list) { double(Twitter::List, id: 8) }
    let(:ar_list) { mock_model(TwitterList) }

    before do
      expect(TwitterClient).to receive(:instance).and_return(client)
      expect(client).to receive(:lists).with(100).and_return([list])
      expect(TwitterData).to receive(:import_list).with(8).and_return(ar_list)
    end

    context 'when the profile twitter lists does not include the imported list' do
      xit 'should append the imported lists to the profile' do
        allow(profile).to receive_message_chain(:twitter_lists, :exists?).with(id: ar_list.id).and_return(false)
        expect(profile.twitter_lists).to receive(:<<).with(ar_list)
        TwitterData.import_twitter_profile_lists(profile)
      end
    end

    context 'when the profile twitter lists include the imported list' do
      xit 'should not append the imported lists to the profile' do
        allow(profile).to receive_message_chain(:twitter_lists, :exists?).with(id: ar_list.id).and_return(true)
        expect(profile.twitter_lists).not_to receive(:<<).with(ar_list)
        TwitterData.import_twitter_profile_lists(profile)
      end
    end
  end

  describe '#import_list' do
    xit 'should create the list' do
      member_ids = [2, 3, 5, 7, 11].freeze
      expect(TwitterData).to receive(:get_list_member_ids).with(100).and_return(member_ids)
      ar_list = mock_model(TwitterList)
      allow(TwitterList).to receive_message_chain(:where, :first_or_initialize).and_return(ar_list)
      expect(ar_list).to receive(:update_attributes!).with(member_ids: member_ids)
      TwitterData.import_list(100)
    end
  end

  describe '#get_list_member_ids' do
    it 'should return member ids' do
      member_ids = [[17, 13, 11], [5, 3, 2], []].freeze
      cursor = double(Twitter::Cursor)

      allow(TwitterClient).to receive(:instance) { client }
      expect(client).to receive(:list_members).with(100, cursor: -1).and_return(cursor)
      expect(client).to receive(:list_members).with(100, cursor: 5).and_return(cursor)

      cursor_attrs = double('cursor attributes')
      allow(cursor).to receive(:attrs).and_return(cursor_attrs)

      allow(cursor_attrs).to receive_message_chain(:[], :map).and_return(member_ids[0], member_ids[1])
      expect(cursor_attrs).to receive(:[]).with(:next_cursor).and_return(5, 0)
      expect(TwitterData.get_list_member_ids(100)).to eq(member_ids.flatten)
    end

    context 'when the twitter api responds with a 404' do
      before do
        allow(client).to receive(:list_members).and_raise(Twitter::Error::NotFound)
        allow(TwitterClient).to receive(:instance) { client }
      end

      it 'should return an empty list' do
        expect(TwitterData.get_list_member_ids(100)).to eq([])
      end
    end
  end

  describe '#refresh_lists_statuses' do
    context 'when there is a list to refresh' do
      it 'should import list members and tweets' do
        list = mock_model(TwitterList)
        allow(TwitterList).to receive_message_chain(:active, :statuses_updated_before).and_return([list])
        expect(list).to receive(:update_column).with(:statuses_updated_at, a_kind_of(Time))
        expect(TwitterData).to receive(:import_list_members_and_tweets).with(list)
        TwitterData.refresh_lists_statuses
      end
    end
  end

  describe '#import_list_member_and_tweets' do
    let(:list) { mock_model(TwitterList, last_status_id: 100) }
    let(:statuses) { double('statuses', empty?: false) }
    let(:status) { double('status', user: double('user')) }

    before { allow(TwitterList).to receive(:find_by_id).and_return(list) }

    it 'should process all tweets' do
      expect(TwitterClient).to receive(:instance).twice.and_return(client)

      expect(client).to receive(:list_timeline).
          with(list.id,
               { since_id: list.last_status_id, count: TwitterData::LIST_TIMELINE_PER_PAGE }).
          and_return(statuses)

      expect(statuses).to receive(:each).and_yield(status)
      expect(TwitterData).to receive(:import_tweet).with(status)

      allow(statuses).to receive_message_chain(:first, :id).and_return(1000)
      allow(statuses).to receive_message_chain(:last, :id).and_return(500)

      expect(statuses).to receive(:length).and_return(TwitterData::LIST_TIMELINE_PER_PAGE)
      expect(client).to receive(:list_timeline).
          with(list.id,
               { since_id: list.last_status_id, max_id: 500, count: TwitterData::LIST_TIMELINE_PER_PAGE }).
          and_return([])
      expect(list).to receive(:update_column).with(:last_status_id, 1000)

      TwitterData.import_list_members_and_tweets(list)
    end
  end

  describe '#get_list_statuses' do
    it 'should return an empty array if the list is not found' do
      expect(TwitterClient).to receive(:instance).and_return(client)
      expect(client).to receive(:list_timeline).and_raise(Twitter::Error::NotFound)
      expect(TwitterData.get_list_statuses(1, {})).to be_empty
    end
  end
end

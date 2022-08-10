# frozen_string_literal: true

require 'spec_helper'

describe 'Twitter rake tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/twitter')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:twitter' do
    describe 'usasearch:twitter:expire' do
      let(:task_name) { 'usasearch:twitter:expire' }

      before { @rake[task_name].reenable }

      it "has 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      context 'when days back is specified' do
        it 'expires tweets that were published more than X days ago' do
          days_back = '7'
          expect(Tweet).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke(days_back)
        end
      end

      context 'when days back is not specified' do
        it 'expires tweets that were published more than 3 days ago' do
          days_back = '3'
          expect(Tweet).to receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke
        end
      end
    end

    describe 'usasearch:twitter:optimize_index' do
      let(:task_name) { 'usasearch:twitter:optimize_index' }

      before do
        allow(ElasticTweet).to receive(:optimize)
      end

      it 'calls ElasticTweet.optimize' do
        expect(ElasticTweet).to receive :optimize
        @rake[task_name].invoke
      end
    end

    describe 'usasearch:twitter:refresh_lists' do
      let(:task_name) { 'usasearch:twitter:refresh_lists' }

      before { @rake[task_name].reenable }

      it 'has environment as a prereq' do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      it 'starts a continuous worker' do
        allow(ContinuousWorker).to receive(:start).and_yield
        expect(TwitterData).to receive :refresh_lists
        @rake[task_name].invoke
      end
    end

    describe 'usasearch:twitter:refresh_lists_statuses' do
      let(:task_name) { 'usasearch:twitter:refresh_lists_statuses' }

      before { @rake[task_name].reenable }

      it 'has environment as a prereq' do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      it 'starts a continuous worker' do
        allow(ContinuousWorker).to receive(:start).and_yield
        expect(TwitterData).to receive :refresh_lists_statuses
        @rake[task_name].invoke
      end
    end

    describe 'usasearch:twitter:stream' do
      attr_reader :stream

      let!(:now) { Time.current }
      let(:task_name) { 'usasearch:twitter:stream' }

      before { @rake[task_name].reenable }

      it "has 'environment' as a prereq" do
        expect(@rake[task_name].prerequisites).to include('environment')
      end

      context 'configuring TweetStream' do
        let(:auth_info) do
          { 'consumer_key' => 'default_consumer_key',
            'consumer_secret' => 'default_consumer_secret',
            'oauth_token' => 'default_oauth_token',
            'oauth_token_secret' => 'default_oauth_secret' }
        end

        before do
          allow(EM).to receive(:run)
          expect(Rails.application.secrets).to receive(:twitter).and_return(auth_info)
        end

        context 'when host argument is not specified' do
          it 'loads the default auth info' do
            config = double('config')
            expect(TweetStream).to receive(:configure).and_yield(config)
            expect(config).to receive(:consumer_key=).with('default_consumer_key')
            expect(config).to receive(:consumer_secret=).with('default_consumer_secret')
            expect(config).to receive(:oauth_token=).with('default_oauth_token')
            expect(config).to receive(:oauth_token_secret=).with('default_oauth_secret')
            expect(config).to receive(:verify_peer=).with(true)
            expect(config).to receive(:cert_chain_file=).with(/\.pem$/)

            @rake[task_name].invoke
          end
        end
      end

      context 'when connecting to Twitter' do
        let(:tweet_status_json) { File.read("#{Rails.root}/spec/fixtures/json/tweet_status.json") }
        let(:tweet_status_with_partial_urls_json) { File.read("#{Rails.root}/spec/fixtures/json/tweet_status_with_partial_urls.json") }
        let(:retweet_status_json) { File.read("#{Rails.root}/spec/fixtures/json/retweet_status.json") }
        let(:active_twitter_ids) { [123].freeze }

        before do
          allow(Time).to receive(:now).and_return(now)
          allow(Twitter).to receive(:user).and_return double('Twitter', id: 123, name: 'USASearch', profile_image_url: 'http://some.gov/url')
          allow(TwitterProfile).to receive(:active_twitter_ids).and_return(active_twitter_ids)

          allow(EM).to receive(:defer).and_yield
          allow(EM).to receive(:stop_event_loop).and_return true
          allow(EventMachine).to receive(:add_periodic_timer).and_return true
          allow(EM).to receive(:run).and_yield

          @other_status = '{"contributors":null,"coordinates":null,"retweet_count":0,"text":"2o piece nugget I just KILLED EM","favorited":false,"in_reply_to_status_id_str":null,"in_reply_to_status_id":null,"in_reply_to_user_id_str":null,"truncated":false,"source":"\u003Ca href=\"http:\/\/twicca.r246.jp\/\" rel=\"nofollow\"\u003Etwicca\u003C\/a\u003E","geo":null,"retweeted":false,"in_reply_to_screen_name":null,"id_str":"195571096760762369","entities":{"hashtags":[],"urls":[],"user_mentions":[]},"user":{"listed_count":1,"profile_background_tile":true,"following":null,"notifications":null,"profile_sidebar_fill_color":"000000","default_profile":false,"show_all_inline_media":true,"time_zone":"Pacific Time (US & Canada)","location":"Walkin In Memphis!","is_translator":false,"profile_sidebar_border_color":"ffffff","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/2166270641\/profile_normal.png","description":"\u00bbINSTAGRAM SmokeeDouble007\u00ab\r\nJust livin the vi$ions always wanted .. makin this life a movie ALONE dont plan on bein held back  ! ,Call me SMOKEE !","follow_request_sent":null,"profile_use_background_image":true,"screen_name":"Im_Smokee_BITCH","default_profile_image":false,"friends_count":558,"profile_text_color":"f7ff00","verified":false,"profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","favourites_count":16,"protected":false,"profile_link_color":"6600ff","name":"SMOKEE \u0394LLEN","id_str":"1234","lang":"en","statuses_count":10368,"profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","created_at":"Sat Jun 25 07:46:43 +0000 2011","followers_count":976,"profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2166270641\/profile_normal.png","id":1234,"contributors_enabled":false,"geo_enabled":false,"utc_offset":-28800,"profile_background_color":"BADFCD","url":null},"in_reply_to_user_id":null,"id":195571096760762369,"created_at":"Thu Apr 26 17:52:37 +0000 2012","place":null}'

          @client = TweetStream::Client.new
          allow(TweetStream::Client).to receive(:new).and_return @client

          @stream = double('stream')
          allow(@stream).to receive(:on_error)
          allow(@stream).to receive(:on_reconnect)
          allow(@stream).to receive(:on_max_reconnects)
          allow(@stream).to receive(:on_unauthorized)
          allow(@stream).to receive(:on_enhance_your_calm)
          allow(@stream).to receive(:on_no_data_received)
          allow(@stream).to receive(:on_close)
          allow(EM::Twitter::Client).to receive(:connect).and_return(@stream)

          @logger = double(ActiveSupport::Logger)
          allow(@logger).to receive(:info).and_return true
          allow(@logger).to receive(:debug).and_return true
          allow(@logger).to receive(:error).and_return true
          allow(ActiveSupport::Logger).to receive(:new).with(Rails.root.to_s + '/log/twitter.log').and_return @logger
        end

        after do
          TweetStream.reset
        end

        it 'get a list of all the TwitterProfile ids, setup various callbacks, and call follow' do
          expect(@client).to receive(:follow).with(active_twitter_ids)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @rake[task_name].invoke
        end

        it 'creates a new tweet for every status received' do
          allow(@stream).to receive(:each).and_yield(tweet_status_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
          @rake[task_name].invoke
          expect(Tweet.count).to eq(1)
          tweet = Tweet.first
          expect(tweet.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
          expect(tweet.urls.map { |url| url['display_url'] }).to eq(%w[search.gov/features pic.twitter.com/y5YSDq7M])
        end

        it 'persists urls with complete data' do
          allow(@stream).to receive(:each).and_yield(tweet_status_with_partial_urls_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
          @rake[task_name].invoke
          expect(Tweet.count).to eq(1)
          tweet = Tweet.first
          expect(tweet.twitter_profile_id).to eq(123)
          expect(tweet.tweet_id).to eq(258289885373423617)
          expect(tweet.tweet_text).to eq('Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M')
          expect(tweet.urls.map { |url| url['display_url'] }).to eq(%w[pic.twitter.com/y5YSDq7M])
        end

        it 'handles retweet' do
          allow(@stream).to receive(:each).and_yield(retweet_status_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: RT @femaregion1: East Coast accounts giving specific #Sandy safety tips @femaregion1 @femaregion2 @FEMAregion3 @femaregion4 http://t.co/ ...")
          expect(TwitterData).to receive(:within_tweet_creation_time_threshold?).and_return(true)
          @rake[task_name].invoke
          expect(Tweet.count).to eq(1)
          tweet = Tweet.first
          expect(tweet.twitter_profile_id).to eq(123)
          expect(tweet.tweet_id).to eq(263164794574626816)
          expect(tweet.tweet_text).to eq("RT @femaregion1: East Coast accounts giving specific #Sandy safety tips @femaregion1 @femaregion2 @FEMAregion3 @femaregion4 http://t.co/odIp5fl7\u2026")
          expect(tweet.urls.map { |url| url['display_url'] }).to eq(%w[fema.gov/colorbox/node/])
        end

        it 'logs an error if something goes wrong in creating a Tweet' do
          allow(@stream).to receive(:each).and_yield(tweet_status_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(@logger).to receive(:error).with("[#{now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=258289885373423617: Some Exception")
          expect(TwitterData).to receive(:import_tweet).and_raise 'Some Exception'
          @rake[task_name].invoke
          expect(Tweet.count).to eq(0)
        end

        it 'only creates a new tweet if the user id matches a TwitterProfile' do
          allow(@stream).to receive(:each).and_yield(@other_status)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          expect(TwitterData).not_to receive(:import_tweet)
          @rake[task_name].invoke
        end

        it 'deletes a status if a delete message is received' do
          Tweet.create!(twitter_profile_id: active_twitter_ids.first,
                        tweet_id: 1234,
                        tweet_text: 'DELETE ME.',
                        published_at: Time.zone.now)
          allow(@stream).to receive(:each).and_yield('{ "delete": { "status": { "id": 1234, "user_id": 3 } } }')
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [ONDELETE] Received delete request for status#1234")
          @rake[task_name].invoke
          expect(Tweet.find_by(tweet_id: 1234)).to be_nil
        end

        it 'logs an error message if one is received' do
          allow(@stream).to receive(:each).and_yield('Bad message')
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:error).with("[#{now}] [TWITTER] [ERROR] MultiJson::DecodeError occured in stream: Bad message")
          @rake[task_name].invoke
        end

        it 'logs when reconnecting' do
          allow(@stream).to receive(:each).and_yield(tweet_status_json)
          allow(@stream).to receive(:on_reconnect).and_yield(10, 1)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [RECONNECT] Reconnecting timeout: 10 retries: 1")
          @rake[task_name].invoke
        end

        it 'reconnects when there are changes on active twitter ids' do
          allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123], [456])
          allow(@client).to receive(:on_interval_time).and_return 1
          expect(EM).to receive(:add_periodic_timer).and_yield
          allow(@stream).to receive(:each).and_yield(tweet_status_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [RESET_STREAM]")
          expect(@client).to receive(:stop_stream)
          @rake[task_name].invoke
        end

        it 'does not stop stream when active twitter ids are the same' do
          allow(TwitterProfile).to receive(:active_twitter_ids).and_return([123], [123])
          allow(@client).to receive(:on_interval_time).and_return 1
          expect(EM).to receive(:add_periodic_timer).and_yield
          allow(@stream).to receive(:each).and_yield(tweet_status_json)
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          expect(@logger).to receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          expect(@client).not_to receive(:stop_stream)
          @rake[task_name].invoke
        end

        context 'when there are no Twitter Profiles' do
          before do
            expect(TwitterProfile).to receive(:active_twitter_ids).and_return([])
          end

          it 'does not connect to Twitter' do
            expect(@client).not_to receive(:follow)
            expect(@logger).not_to receive(:info)
            @rake[task_name].invoke
          end
        end
      end
    end
  end
end

require 'spec_helper'

describe "Twitter rake tasks" do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/twitter')
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:twitter" do
    describe "usasearch:twitter:expire" do
      let(:task_name) { 'usasearch:twitter:expire' }
      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      context "when days back is specified" do
        it "should expire tweets that were published more than X days ago" do
          days_back = "7"
          Tweet.should_receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke(days_back)
        end
      end

      context "when days back is not specified" do
        it "should expire tweets that were published more than 3 days ago" do
          days_back = "3"
          Tweet.should_receive(:expire).with(days_back.to_i)
          @rake[task_name].invoke
        end
      end
    end

    describe 'usasearch:twitter:optimize_index' do
      let(:task_name) { 'usasearch:twitter:optimize_index' }

      before do
        ElasticTweet.stub(:optimize)
      end

      it 'should call ElasticTweet.optimize' do
        ElasticTweet.should_receive :optimize
        @rake[task_name].invoke
      end
    end

    describe 'usasearch:twitter:refresh_lists' do
      let(:task_name) { 'usasearch:twitter:refresh_lists' }

      before { @rake[task_name].reenable }

      it 'should have environment as a prereq' do
        @rake[task_name].prerequisites.should include('environment')
      end

      it 'should start a continuous worker' do
        ContinuousWorker.stub(:start).and_yield
        TwitterData.should_receive :refresh_lists
        @rake[task_name].invoke
      end
    end

    describe 'usasearch:twitter:refresh_lists_statuses' do
      let(:task_name) { 'usasearch:twitter:refresh_lists_statuses' }

      before { @rake[task_name].reenable }

      it 'should have environment as a prereq' do
        @rake[task_name].prerequisites.should include('environment')
      end

      it 'should start a continuous worker' do
        ContinuousWorker.stub(:start).and_yield
        TwitterData.should_receive :refresh_lists_statuses
        @rake[task_name].invoke
      end
    end

    describe "usasearch:twitter:stream" do
      attr_reader :stream

      let!(:now) { Time.current }
      let(:task_name) { 'usasearch:twitter:stream' }

      before { @rake[task_name].reenable }

      it "should have 'environment' as a prereq" do
        @rake[task_name].prerequisites.should include("environment")
      end

      context 'configuring TweetStream' do
        let(:auth_info) do
          { 'default' => { 'consumer_key' => 'default_consumer_key',
                           'consumer_secret' => 'default_consumer_secret',
                           'oauth_token' => 'default_oauth_token',
                           'oauth_token_secret' => 'default_oauth_secret' },
            'cron' => { 'consumer_key' => 'default_consumer_key',
                        'consumer_secret' => 'default_consumer_secret',
                        'oauth_token' => 'cron_oauth_token',
                        'oauth_token_secret' => 'cron_oauth_secret' } }
        end

        before do
          EM.stub!(:run)
          YAML.should_receive(:load_file).and_return(auth_info)
        end

        context 'when host argument is not specified' do
          it 'should load default auth info' do
            config = mock('config')
            TweetStream.should_receive(:configure).and_yield(config)
            config.should_receive(:consumer_key=).with('default_consumer_key')
            config.should_receive(:consumer_secret=).with('default_consumer_secret')
            config.should_receive(:oauth_token=).with('default_oauth_token')
            config.should_receive(:oauth_token_secret=).with('default_oauth_secret')

            @rake[task_name].invoke
          end
        end

        context 'when valid host argument is specified' do
          it 'should load matching auth info' do
            config = mock('config')
            TweetStream.should_receive(:configure).and_yield(config)
            config.should_receive(:consumer_key=).with('default_consumer_key')
            config.should_receive(:consumer_secret=).with('default_consumer_secret')
            config.should_receive(:oauth_token=).with('cron_oauth_token')
            config.should_receive(:oauth_token_secret=).with('cron_oauth_secret')

            @rake[task_name].invoke('cron')
          end
        end

        context 'when invalid host argument is specified' do
          it 'should load default auth info' do
            config = mock('config')
            TweetStream.should_receive(:configure).and_yield(config)
            config.should_receive(:consumer_key=).with('default_consumer_key')
            config.should_receive(:consumer_secret=).with('default_consumer_secret')
            config.should_receive(:oauth_token=).with('default_oauth_token')
            config.should_receive(:oauth_token_secret=).with('default_oauth_secret')

            @rake[task_name].invoke('doesnotexist')
          end
        end
      end

      context "when connecting to Twitter" do
        let(:tweet_status_json) { File.read("#{Rails.root}/spec/fixtures/json/tweet_status.json") }
        let(:tweet_status_with_partial_urls_json) { File.read("#{Rails.root}/spec/fixtures/json/tweet_status_with_partial_urls.json") }
        let(:retweet_status_json) { File.read("#{Rails.root}/spec/fixtures/json/retweet_status.json") }
        let(:active_twitter_ids) { [123].freeze }

        before(:each) do
          Time.stub!(:now).and_return(now)
          Twitter.stub!(:user).and_return mock('Twitter', :id => 123, :name => 'USASearch', :profile_image_url => 'http://some.gov/url')
          TwitterProfile.stub(:active_twitter_ids).and_return(active_twitter_ids)

          EM.stub!(:defer).and_yield
          EM.stub!(:stop_event_loop).and_return true
          EventMachine.stub!(:add_periodic_timer).and_return true
          EM.stub!(:run).and_yield

          @other_status = '{"contributors":null,"coordinates":null,"retweet_count":0,"text":"2o piece nugget I just KILLED EM","favorited":false,"in_reply_to_status_id_str":null,"in_reply_to_status_id":null,"in_reply_to_user_id_str":null,"truncated":false,"source":"\u003Ca href=\"http:\/\/twicca.r246.jp\/\" rel=\"nofollow\"\u003Etwicca\u003C\/a\u003E","geo":null,"retweeted":false,"in_reply_to_screen_name":null,"id_str":"195571096760762369","entities":{"hashtags":[],"urls":[],"user_mentions":[]},"user":{"listed_count":1,"profile_background_tile":true,"following":null,"notifications":null,"profile_sidebar_fill_color":"000000","default_profile":false,"show_all_inline_media":true,"time_zone":"Pacific Time (US & Canada)","location":"Walkin In Memphis!","is_translator":false,"profile_sidebar_border_color":"ffffff","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/2166270641\/profile_normal.png","description":"\u00bbINSTAGRAM SmokeeDouble007\u00ab\r\nJust livin the vi$ions always wanted .. makin this life a movie ALONE dont plan on bein held back  ! ,Call me SMOKEE !","follow_request_sent":null,"profile_use_background_image":true,"screen_name":"Im_Smokee_BITCH","default_profile_image":false,"friends_count":558,"profile_text_color":"f7ff00","verified":false,"profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","favourites_count":16,"protected":false,"profile_link_color":"6600ff","name":"SMOKEE \u0394LLEN","id_str":"1234","lang":"en","statuses_count":10368,"profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","created_at":"Sat Jun 25 07:46:43 +0000 2011","followers_count":976,"profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2166270641\/profile_normal.png","id":1234,"contributors_enabled":false,"geo_enabled":false,"utc_offset":-28800,"profile_background_color":"BADFCD","url":null},"in_reply_to_user_id":null,"id":195571096760762369,"created_at":"Thu Apr 26 17:52:37 +0000 2012","place":null}'

          @client = TweetStream::Client.new
          TweetStream::Client.stub!(:new).and_return @client

          @stream = mock('stream')
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @stream.stub!(:on_unauthorized)
          @stream.stub!(:on_enhance_your_calm)
          @stream.stub!(:on_no_data_received)
          EM::Twitter::Client.stub!(:connect).and_return(@stream)

          @logger = mock(ActiveSupport::BufferedLogger)
          @logger.stub!(:info).and_return true
          @logger.stub!(:debug).and_return true
          @logger.stub!(:error).and_return true
          ActiveSupport::BufferedLogger.stub!(:new).with(Rails.root.to_s + "/log/twitter.log").and_return @logger
        end

        after(:each) do
          TweetStream.reset
        end

        it "get a list of all the TwitterProfile ids, setup various callbacks, and call follow" do
          @client.should_receive(:follow).with(active_twitter_ids)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @rake[task_name].invoke
        end

        it "should create a new tweet for every status received" do
          @stream.stub!(:each).and_yield(tweet_status_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          TwitterData.should_receive(:within_tweet_creation_time_threshold?) { true }
          @rake[task_name].invoke
          Tweet.count.should == 1
          tweet = Tweet.first
          tweet.tweet_text.should == 'Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M'
          tweet.urls.collect(&:display_url).should == %w(usasearch.howto.gov/features pic.twitter.com/y5YSDq7M)
        end

        it 'should persist urls with complete data' do
          @stream.stub!(:each).and_yield(tweet_status_with_partial_urls_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          TwitterData.should_receive(:within_tweet_creation_time_threshold?).and_return(true)
          @rake[task_name].invoke
          Tweet.count.should == 1
          tweet = Tweet.first
          tweet.twitter_profile_id.should == 123
          tweet.tweet_id.should == 258289885373423617
          tweet.tweet_text.should == 'Fast. Relevant. Free. Features: http://t.co/l8VhWiZH http://t.co/y5YSDq7M'
          tweet.urls.collect(&:display_url).should == %w(pic.twitter.com/y5YSDq7M)
        end

        it 'should handle retweet' do
          @stream.stub!(:each).and_yield(retweet_status_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: RT @femaregion1: East Coast accounts giving specific #Sandy safety tips @femaregion1 @femaregion2 @FEMAregion3 @femaregion4 http://t.co/ ...")
          TwitterData.should_receive(:within_tweet_creation_time_threshold?).and_return(true)
          @rake[task_name].invoke
          Tweet.count.should == 1
          tweet = Tweet.first
          tweet.twitter_profile_id.should == 123
          tweet.tweet_id.should == 263164794574626816
          tweet.tweet_text.should == "RT @femaregion1: East Coast accounts giving specific #Sandy safety tips @femaregion1 @femaregion2 @FEMAregion3 @femaregion4 http://t.co/odIp5fl7\u2026"
          tweet.urls.collect(&:display_url).should == %w(fema.gov/colorbox/node/)
        end

        it "should log an error if something goes wrong in creating a Tweet" do
          @stream.stub!(:each).and_yield(tweet_status_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          @logger.should_receive(:error).with("[#{now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=258289885373423617: Some Exception")
          TwitterData.should_receive(:import_tweet).and_raise "Some Exception"
          @rake[task_name].invoke
          Tweet.count.should == 0
        end

        it "should only create a new tweet if the user id matches a TwitterProfile" do
          @stream.stub!(:each).and_yield(@other_status)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          TwitterData.should_not_receive(:import_tweet)
          @rake[task_name].invoke
        end

        it "should delete a status if a delete message is received" do
          Tweet.create!(:twitter_profile_id => active_twitter_ids.first,
                        :tweet_id => 1234,
                        :tweet_text => 'DELETE ME.',
                        :published_at => Time.now)
          @stream.stub!(:each).and_yield('{ "delete": { "status": { "id": 1234, "user_id": 3 } } }')
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [ONDELETE] Received delete request for status#1234")
          @rake[task_name].invoke
          Tweet.find_by_tweet_id(1234).should be_nil
        end

        it "should log an error message if one is received" do
          @stream.stub!(:each).and_yield('Bad message')
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:error).with("[#{now}] [TWITTER] [ERROR] MultiJson::DecodeError occured in stream: Bad message")
          @rake[task_name].invoke
        end

        it "should log when reconnecting" do
          @stream.stub!(:each).and_yield(tweet_status_json)
          @stream.stub!(:on_reconnect).and_yield(10, 1)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [RECONNECT] Reconnecting timeout: 10 retries: 1")
          @rake[task_name].invoke
        end

        it 'reconnects when there are changes on active twitter ids' do
          TwitterProfile.stub(:active_twitter_ids).and_return([123], [456])
          @client.stub!(:on_interval_time).and_return 1
          EM.should_receive(:add_periodic_timer).and_yield
          @stream.stub!(:each).and_yield(tweet_status_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [RESET_STREAM]")
          @client.should_receive(:stop_stream)
          @rake[task_name].invoke
        end

        it 'does not stop stream when active twitter ids are the same' do
          TwitterProfile.stub(:active_twitter_ids).and_return([123], [123])
          @client.stub!(:on_interval_time).and_return 1
          EM.should_receive(:add_periodic_timer).and_yield
          @stream.stub!(:each).and_yield(tweet_status_json)
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[#{now}] [TWITTER] [FOLLOW] New tweet received: @usasearchdev: Fast. Relevant. Free.\nFeatures: http:\/\/t.co\/l8VhWiZH http:\/\/t.co\/y5YSDq7M")
          @client.should_not_receive(:stop_stream)
          @rake[task_name].invoke
        end

        context "when there are no Twitter Profiles" do
          before do
            TwitterProfile.should_receive(:active_twitter_ids).and_return([])
          end

          it "should not connect to Twitter" do
            @client.should_not_receive(:follow)
            @logger.should_not_receive(:info)
            @rake[task_name].invoke
          end
        end
      end
    end
  end
end

require 'spec/spec_helper'

describe "Twitter rake tasks" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/twitter"
    Rake::Task.define_task(:environment)
  end

  describe "usasearch:twitter" do
    describe "usasearch:twitter:stream" do
      attr_reader :stream
      before do
        @task_name = "usasearch:twitter:stream"
      end

      it "should have 'environment' as a prereq" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      context "when connecting to Twitter" do
        before(:each) do
          TwitterProfile.create!(:twitter_id => 123, :screen_name => 'USASearch', :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')

          EM.stub!(:defer).and_yield
          EM.stub!(:stop_event_loop).and_return true
          EM.stub!(:add_periodic_timer).and_return true
          EM.stub!(:run).and_yield

          @raw_status = '{"contributors":null,"coordinates":null,"retweet_count":0,"text":"2o piece nugget I just KILLED EM","favorited":false,"in_reply_to_status_id_str":null,"in_reply_to_status_id":null,"in_reply_to_user_id_str":null,"truncated":false,"source":"\u003Ca href=\"http:\/\/twicca.r246.jp\/\" rel=\"nofollow\"\u003Etwicca\u003C\/a\u003E","geo":null,"retweeted":false,"in_reply_to_screen_name":null,"id_str":"195571096760762369","entities":{"hashtags":[],"urls":[],"user_mentions":[]},"user":{"listed_count":1,"profile_background_tile":true,"following":null,"notifications":null,"profile_sidebar_fill_color":"000000","default_profile":false,"show_all_inline_media":true,"time_zone":"Pacific Time (US & Canada)","location":"Walkin In Memphis!","is_translator":false,"profile_sidebar_border_color":"ffffff","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/2166270641\/profile_normal.png","description":"\u00bbINSTAGRAM SmokeeDouble007\u00ab\r\nJust livin the vi$ions always wanted .. makin this life a movie ALONE dont plan on bein held back  ! ,Call me SMOKEE !","follow_request_sent":null,"profile_use_background_image":true,"screen_name":"Im_Smokee_BITCH","default_profile_image":false,"friends_count":558,"profile_text_color":"f7ff00","verified":false,"profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","favourites_count":16,"protected":false,"profile_link_color":"6600ff","name":"SMOKEE \u0394LLEN","id_str":"123","lang":"en","statuses_count":10368,"profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","created_at":"Sat Jun 25 07:46:43 +0000 2011","followers_count":976,"profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2166270641\/profile_normal.png","id":123,"contributors_enabled":false,"geo_enabled":false,"utc_offset":-28800,"profile_background_color":"BADFCD","url":null},"in_reply_to_user_id":null,"id":195571096760762369,"created_at":"Thu Apr 26 17:52:37 +0000 2012","place":null}'
          @other_status = '{"contributors":null,"coordinates":null,"retweet_count":0,"text":"2o piece nugget I just KILLED EM","favorited":false,"in_reply_to_status_id_str":null,"in_reply_to_status_id":null,"in_reply_to_user_id_str":null,"truncated":false,"source":"\u003Ca href=\"http:\/\/twicca.r246.jp\/\" rel=\"nofollow\"\u003Etwicca\u003C\/a\u003E","geo":null,"retweeted":false,"in_reply_to_screen_name":null,"id_str":"195571096760762369","entities":{"hashtags":[],"urls":[],"user_mentions":[]},"user":{"listed_count":1,"profile_background_tile":true,"following":null,"notifications":null,"profile_sidebar_fill_color":"000000","default_profile":false,"show_all_inline_media":true,"time_zone":"Pacific Time (US & Canada)","location":"Walkin In Memphis!","is_translator":false,"profile_sidebar_border_color":"ffffff","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/2166270641\/profile_normal.png","description":"\u00bbINSTAGRAM SmokeeDouble007\u00ab\r\nJust livin the vi$ions always wanted .. makin this life a movie ALONE dont plan on bein held back  ! ,Call me SMOKEE !","follow_request_sent":null,"profile_use_background_image":true,"screen_name":"Im_Smokee_BITCH","default_profile_image":false,"friends_count":558,"profile_text_color":"f7ff00","verified":false,"profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","favourites_count":16,"protected":false,"profile_link_color":"6600ff","name":"SMOKEE \u0394LLEN","id_str":"1234","lang":"en","statuses_count":10368,"profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/535874821\/lil_b_basedgod299.jpg","created_at":"Sat Jun 25 07:46:43 +0000 2011","followers_count":976,"profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/2166270641\/profile_normal.png","id":1234,"contributors_enabled":false,"geo_enabled":false,"utc_offset":-28800,"profile_background_color":"BADFCD","url":null},"in_reply_to_user_id":null,"id":195571096760762369,"created_at":"Thu Apr 26 17:52:37 +0000 2012","place":null}'

          @client = TweetStream::Client.new
          TweetStream.stub!(:new).and_return @client

          @stream = mock(Twitter::JSONStream)
          Twitter::JSONStream.stub!(:connect).and_return(@stream)

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
          @client.should_receive(:on_delete)
          @client.should_receive(:on_error)
          @client.should_receive(:on_reconnect)
          @client.should_receive(:on_interval).with(3600)
          @client.should_receive(:follow).with(TwitterProfile.all.collect(&:twitter_id))
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @rake[@task_name].invoke("true")
        end

        it "should create a new tweet for every status received" do
          @stream.stub!(:each_item).and_yield(@raw_status)
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          @rake[@task_name].invoke("true")
          Tweet.count.should == 1
          Tweet.first.tweet_text.should == "2o piece nugget I just KILLED EM"
        end

        it "should log an error if something goes wrong in creating a Tweet" do
          @stream.stub!(:each_item).and_yield(@raw_status)
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          @logger.should_receive(:error).with("[TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=195571096760762369: Some Exception")
          Tweet.stub!(:create).and_raise "Some Exception"
          @rake[@task_name].invoke("true")
          Tweet.count.should == 0
        end

        it "should only create a new tweet if the user id matches a TwitterProfile" do
          Tweet.count.should == 0
          @stream.stub!(:each_item).and_yield(@other_status)
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          @rake[@task_name].invoke("true")
          Tweet.count.should == 0
        end

        it "should delete a status if a delete message is received" do
          Tweet.create!(:twitter_profile_id => TwitterProfile.first.id, :tweet_id => 1234, :tweet_text => 'DELETE ME.', :published_at => Time.now)
          @stream.stub!(:each_item).and_yield('{ "delete": { "status": { "id": 1234, "user_id": 3 } } }')
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [ONDELETE] Received delete request for status#1234")
          @rake[@task_name].invoke("true")
          Tweet.find_by_tweet_id(1234).should be_nil
        end

        it "should log an error message if one is received" do
          @stream.stub!(:each_item).and_yield('Bad message')
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:error).with("[TWITTER] [ERROR] MultiJson::DecodeError occured in stream: Bad message")
          @rake[@task_name].invoke("true")
        end

        it "should log when reconnecting" do
          timestamp = Time.now
          Time.stub!(:now).and_return timestamp
          @stream.stub!(:each_item).and_yield(@raw_status)
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect).and_yield(1, 1)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          @logger.should_receive(:info).with("[TWITTER] [RECONNECT] Reconnecting at #{timestamp.in_time_zone('UTC').strftime('%a %b %d %H:%M:%S %Z %Y')}...")
          @rake[@task_name].invoke("true")
        end

        it "should reconnect every hour" do
          @client.stub!(:on_interval_time).and_return 1
          EM.should_receive(:add_periodic_timer).and_yield
          @stream.stub!(:each_item).and_yield(@raw_status)
          @stream.stub!(:on_error)
          @stream.stub!(:on_reconnect)
          @stream.stub!(:on_max_reconnects)
          @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 1 Twitter profiles.")
          @logger.should_receive(:info).with("[TWITTER] [FOLLOW] New tweet received: @Im_Smokee_BITCH: 2o piece nugget I just KILLED EM")
          @logger.should_receive(:info).with("[TWITTER] [ONINTERVAL] Time has elapsed, shutting down connection.")
          @client.should_receive(:stop)
          @rake[@task_name].invoke("true")
        end

        context "when there are no Twitter Profiles" do
          before do
            TwitterProfile.destroy_all
          end

          it "should not connect to Twitter" do
            @client.should_receive(:on_delete)
            @client.should_receive(:on_error)
            @client.should_receive(:on_reconnect)
            @client.should_receive(:on_interval).with(3600)
            @client.should_not_receive(:follow)
            @logger.should_receive(:info).with("[TWITTER] [CONNECT] Connecting to Twitter to follow 0 Twitter profiles.")
            @rake[@task_name].invoke("true")
          end
        end
      end
    end
  end
end
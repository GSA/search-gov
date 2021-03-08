require 'spec_helper'

describe TwitterProfilesHelper do
  fixtures :affiliates

  describe '#legacy_render_tweet_text' do
    let(:tweet_text) { 'Search Notes for the Week Ending September 21, 2012 - http://t.co/YQQSs9bb http://t.co/YQQSs9bb' }
    let(:tweet) do
      urls = [double(Twitter::Entity::Url,
                   url: 'http://t.co/YQQSs9bb',
                   expanded_url: 'http://tmblr.co/Z8xAVxUEKvaK',
                   display_url: 'tmblr.co/Z8xAVxUEKvaK'),
              double(Twitter::Entity::Url,
                   url: 'http://t.co/YQQSs9bb',
                   expanded_url: 'http://tmblr.co/Z8xAVxUEKvaK',
                   display_url: 'tmblr.co/Z8xAVxUEKvaK')]
      mock_model(Tweet, tweet_text: tweet_text, urls: urls)
    end
    let(:search) { double(Search, query: 'notes', queried_at_seconds: 1350362825, vertical: :web)}

    before do
      @affiliate = affiliates(:usagov_affiliate)
      @search_vertical = :web
    end

    it 'should render tweet link with click tracking' do
      # TO REMOVE SRCH-1525
      result = helper.legacy_render_tweet_text(tweet, search, 1)
      expect(result).to eq(%q[Search Notes for the Week Ending September 21, 2012 - <a href="http://t.co/YQQSs9bb" onmousedown="return clk('notes', 'http://tmblr.co/Z8xAVxUEKvaK', 2, 'usagov', 'TWEET', 1350362825, 'web', 'en')">tmblr.co/Z8xAVxUEKvaK</a> <a href="http://t.co/YQQSs9bb" onmousedown="return clk('notes', 'http://tmblr.co/Z8xAVxUEKvaK', 2, 'usagov', 'TWEET', 1350362825, 'web', 'en')">tmblr.co/Z8xAVxUEKvaK</a>])
    end
  end

  describe '#legacy_render_twitter_profile' do
    let(:profile) { mock_model(TwitterProfile, link_to_profile: 'http://twitter.com/USASearch')}
    let(:search) { double(Search, query: 'notes', queried_at_seconds: 1350362825)}

    before do
      @affiliate = affiliates(:usagov_affiliate)
      @search_vertical = :web
    end

    it 'should render link with click tracking' do
    # TO REMOVE SRCH-1525
      result = helper.legacy_render_twitter_profile(profile, search, 1)
      expect(result).to eq(%Q[<a href="http://twitter.com/USASearch" onmousedown="return clk('notes', this.href, 2, 'usagov', 'TWEET', 1350362825, 'web', 'en')">\n<span class="screen-name"> @</span></a>])
    end
  end
end

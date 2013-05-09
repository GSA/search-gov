module TwitterData
  GET_LISTS_RATE_LIMIT = 15.freeze
  RATE_LIMIT_RESET_WINDOW = 15.minutes.freeze
  MAX_RETRY_ATTEMPTS = 3.freeze
  MAX_GET_LIST_TWEETS_ATTEMPTS = 5.freeze
  LIST_TIMELINE_PER_PAGE = 200.freeze

  def self.import_profile(twitter_user)
    profile = TwitterProfile.where(twitter_id: twitter_user.id).first_or_initialize
    profile.screen_name = twitter_user.screen_name
    profile.name = twitter_user.name
    profile.profile_image_url = twitter_user.profile_image_url
    profile.save(validate: false)
  end

  def self.import_tweet(status)
    tweet = Tweet.where(tweet_id: status.id).first_or_initialize
    return unless tweet.new_record?

    if status.retweet?
      original_status = status.retweeted_status
      text = "RT @#{original_status.user.screen_name}: #{original_status.text}"
    else
      original_status = status
      text = original_status.text
    end

    urls = []
    urls << original_status.urls if original_status.urls.present?
    urls << original_status.media if original_status.media.present?
    urls.flatten!

    sanitized_urls = urls.select do |u|
      u.display_url.present? && u.expanded_url.present? && u.url.present?
    end.collect do |u|
      Struct.new(:display_url, :expanded_url, :url).new(u.display_url, u.expanded_url, u.url)
    end

    tweet.update_attributes!(tweet_text: text,
                             published_at: original_status.created_at,
                             twitter_profile_id: status.user.id,
                             urls: sanitized_urls)
  end

  def self.refresh_lists
    TwitterProfile.show_lists_enabled.limit(GET_LISTS_RATE_LIMIT).each do |profile|
      profile.touch
      import_twitter_profile_lists(profile)
    end
  end

  def self.import_twitter_profile_lists(profile)
    TwitterApiRunner.run { Twitter.lists(profile.twitter_id) }.each do |list|
      twitter_list = import_list(list.id)
      profile.twitter_lists << twitter_list unless profile.twitter_lists.exists?(twitter_list.id)
    end
  end

  def self.import_list(list_id)
    member_ids = get_list_member_ids(list_id)
    twitter_list = TwitterList.where(id: list_id).first_or_initialize
    twitter_list.update_attributes!(member_ids: member_ids)
    twitter_list
  end

  def self.get_list_member_ids(list_id)
    member_ids = []
    next_cursor = -1
    until next_cursor.zero? do
      TwitterApiRunner.run do
        cursor = Twitter.list_members(list_id, cursor: next_cursor)
        member_ids.push(*cursor.users.map(&:id))
        next_cursor = cursor.next_cursor
      end
    end
    member_ids.uniq
  end

  def self.refresh_lists_statuses
    TwitterList.active.statuses_updated_before(RATE_LIMIT_RESET_WINDOW.ago).each do |list|
      list.update_column(:statuses_updated_at, Time.current)
      import_list_members_and_tweets(list)
    end
  end

  def self.import_list_members_and_tweets(list)
    options = { since_id: list.last_status_id, count: LIST_TIMELINE_PER_PAGE }
    max_last_status_id = list.last_status_id
    MAX_GET_LIST_TWEETS_ATTEMPTS.times do
      break if (statuses = get_list_statuses(list.id, options)).empty?
      statuses.each do |status|
        import_profile(status.user)
        import_tweet(status)
      end
      max_last_status_id = [max_last_status_id, statuses.first.id].max
      break if statuses.length < LIST_TIMELINE_PER_PAGE
      options[:max_id] = statuses.last.id
    end
    list.update_column(:last_status_id, max_last_status_id)
  end

  def self.get_list_statuses(list_id, options)
    TwitterApiRunner.run { Twitter.list_timeline(list_id, options) }
  rescue Twitter::Error::NotFound
    []
  end

  def self.configure_twitter_auth(host)
    Twitter.configure do |config|
      twitter_config = YAML.load_file("#{Rails.root}/config/twitter.yml")
      twitter_auth = twitter_config[host] ? twitter_config[host] : twitter_config['default']
      twitter_auth.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
end
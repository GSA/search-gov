require 'google/api_client'

module YoutubeAdapter
  Google::APIClient.logger = Rails.logger
  CONFIG = YAML.load_file("#{Rails.root}/config/youtube.yml")[Rails.env].freeze

  def self.get_channel_id_by_username(username)
    params = {
      forUsername: username,
      part: 'id'
    }
    first_item(youtube_api.channels.list, params) { |item| item.id }
  end

  def self.get_channel_title(channel_id)
    params = {
      id: channel_id,
      part: 'snippet'
    }
    first_item(youtube_api.channels.list, params) { |item| item.snippet.title }
  end

  def self.get_playlist_ids(channel_id)
    playlist_ids = get_custom_playlist_ids channel_id
    playlist_ids << get_uploads_playlist_id(channel_id)
    playlist_ids.compact.uniq
  end

  def self.get_uploads_playlist_id(channel_id)
    params = {
      id: channel_id,
      part: 'contentDetails'
    }
    first_item(youtube_api.channels.list, params, true) do |item|
      item.content_details.related_playlists.uploads rescue nil
    end
  end

  def self.get_custom_playlist_ids(channel_id)
    params = {
      channelId: channel_id,
      maxResults: 50,
      part: 'id,status'
    }

    playlist_ids = []
    result_items!(youtube_api.playlists.list, params) do |items|
      playlist_ids |= items.collect do |item|
        item.id if 'public' == item.status.privacy_status
      end.compact
    end
    playlist_ids
  end

  def self.each_playlist_item(playlist)
    params = {
      maxResults: 50,
      part: 'snippet,status',
      playlistId: playlist.playlist_id
    }
    headers = { 'If-None-Match' => playlist.etag } if playlist.etag.present?
    result_items!(youtube_api.playlist_items.list, params, headers) do |items|
      items.each do |item|
        yield item if 'public' == item.status.privacy_status
      end
    end
  end

  def self.each_video(video_ids)
    return if video_ids.blank?

    result = client.execute(api_method: youtube_api.videos.list,
                            authenticated: false,
                            parameters: { id: video_ids.join(','),
                                          part: 'contentDetails' })
    on_result_with_items(result, false) do |items|
      items.each { |item| yield item }
    end
  end

  def self.youtube_api
    @@youtube_api ||= begin
      doc = Rails.root.join('config/youtube_discovered_api.json').read
      client.register_discovery_document('youtube', 'v3', doc)
      client.discovered_api('youtube', 'v3')
    end
  end

  def self.client
    @@client ||= begin
      options = {
        application_name: 'DGSearch',
        faraday_option: {
          open_timeout: 2,
          timeout: 5
        },
        key: CONFIG['key']
      }
      Google::APIClient.new options
    end
  end

  private

  def self.first_item(api_method, params, raise_on_error = false)
    result = client.execute(api_method: api_method,
                            authenticated: false,
                            parameters: params)
    on_result_with_items(result, raise_on_error) do |items|
      yield items.first if items.first.present?
    end
  end

  def self.result_items!(api_method, params_without_page_token, headers = nil)
    next_page_token = ''
    first_result = nil

    until next_page_token.nil?
      params = params_without_page_token.merge(pageToken: next_page_token)
      result = client.execute(api_method: api_method,
                              authenticated: false,
                              headers: headers,
                              parameters: params)
      first_result = result if '' == next_page_token
      break if 304 == first_result.status

      on_result_with_items(result, true) { |items| yield items }
      next_page_token = result.next_page_token
    end
    first_result
  end

  def self.on_result_with_items(result, raise_on_error)
    if result.success?
      yield result.data.items if result.data && result.data.items.present?
    elsif raise_on_error
      raise StandardError.new("YouTube API status: #{result.status} error message: #{result.error_message}")
    end
  end
end

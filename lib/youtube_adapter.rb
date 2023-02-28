require 'google/apis/youtube_v3'

module YoutubeAdapter
  Google::Apis.logger = Rails.logger
  @@client = nil

  def self.get_channel_id_by_username(username)
    params = {
      for_username: username,
    }
    first_channel('id', **params) { |item| item.id }
  end

  def self.get_channel_title(channel_id)
    params = {
      id: channel_id,
    }
    first_channel('snippet', params) { |item| item.snippet.title }
  end

  def self.get_playlist_ids(channel_id)
    playlist_ids = get_custom_playlist_ids channel_id
    playlist_ids << get_uploads_playlist_id(channel_id)
    playlist_ids.compact.uniq
  end

  def self.get_uploads_playlist_id(channel_id)
    params = {
      id: channel_id,
    }
    first_channel('contentDetails', params, true) do |item|
      item.content_details.related_playlists.uploads rescue nil
    end
  end

  def self.get_custom_playlist_ids(channel_id)
    params = {
      channel_id: channel_id,
      max_results: 50,
    }

    playlist_ids = []
    playlists('id,status', params) do |items|
      playlist_ids |= items.collect do |item|
        item.id if 'public' == item.status.privacy_status
      end.compact
    end
    playlist_ids
  end

  def self.each_playlist_item(playlist)
    params = {
      max_results: 50,
      playlist_id: playlist.playlist_id
    }
    headers = { 'If-None-Match' => playlist.etag } if playlist.etag.present?
    playlist_items('snippet,status', params, headers) do |items|
      items.each do |item|
        yield item if 'public' == item.status.privacy_status
      end
    end
  end

  def self.each_video(video_ids)
    return if video_ids.blank?

    client.list_videos('contentDetails', id: video_ids.join(',')) do |result, error|
      on_result_with_items(result, error, false) do |items|
        items.each { |item| yield item }
      end
    end
  end

  def self.client
    return @@client if @@client
    @@client = Google::Apis::YoutubeV3::YouTubeService.new
    @@client.key = Rails.application.secrets.youtube[:key]
    @@client.client_options.application_name = 'DGSearch'
    @@client.client_options.open_timeout_sec = 2
    @@client.client_options.read_timeout_sec = 5
    @@client
  end

  private

  def self.first_channel(part, params, raise_on_error = false)
    channel = nil
    client.list_channels(part, **params) do |result, error|
      on_result_with_items(result, error, raise_on_error) do |items|
        channel = yield items.first if items.first.present?
      end
    end
    channel
  end

  def self.playlists(part, params_without_page_token, headers = nil, &block)
    self.playlists_or_playlist_items(:playlists,
      part: part,
      params: params_without_page_token,
      headers: headers,
      &block
    )
  end

  def self.playlist_items(part, params_without_page_token, headers = nil, &block)
    self.playlists_or_playlist_items(:playlist_items,
      part: part,
      params: params_without_page_token,
      headers: headers,
      &block
    )
  end

  def self.playlists_or_playlist_items(what_to_list, opts = {})
    next_page_token = ''
    return_value = nil
    request_options = Google::Apis::RequestOptions.new
    request_options.header = opts[:headers]

    until next_page_token.nil?
      params = opts[:params].merge(page_token: next_page_token, options: request_options)
      client.send(:"list_#{what_to_list}", opts[:part], **params) do |result, error|
        return_value ||= first_result(result, error)
        if return_value.status_code == 304
          next_page_token = nil
          break
        else
          on_result_with_items(result, error, true) { |items| yield items }
          next_page_token = result.next_page_token
        end
      end
    end

    return_value || first_result
  end

  def self.first_result(result=nil, error=nil)
    OpenStruct.new(
      etag: result&.etag,
      status_code: error&.status_code
    )
  end

  def self.on_result_with_items(result, error, raise_on_error)
    if error && raise_on_error
      raise StandardError.new("YouTube API status: #{error&.status_code} error message: #{error&.message}")
    else
      yield result.items if result&.items&.present?
    end
  end
end

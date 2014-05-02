class YoutubePlaylistVideosParser
  include YoutubeVideosParser

  def initialize(playlist_id)
    @playlist_id = playlist_id
  end

  protected

  def document_url(start_index = 1)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:'max-results'] = MAX_RESULTS_PER_FEED
    url_params[:'start-index'] = start_index
    "http://gdata.youtube.com/feeds/api/playlists/#{@playlist_id}?#{url_params.to_param}"
  end
end

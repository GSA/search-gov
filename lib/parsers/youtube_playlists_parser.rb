class YoutubePlaylistsParser
  include YoutubeVideosParser

  def initialize(username)
    @username = username
  end

  def playlist_ids
    document_url = playlist_ids_url
    ids = []
    while document_url do
      doc = feed_document(document_url)
      doc.xpath('//item').each do |item|
        ids << item.xpath('yt:playlistId').inner_text
      end
      document_url = next_playlist_ids_url(doc)
    end
    ids
  end

  private

  def playlist_ids_url(start_index = 1)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:'max-results'] = MAX_RESULTS_PER_FEED
    url_params[:'start-index'] = start_index
    "http://gdata.youtube.com/feeds/api/users/#{@username}/playlists?#{url_params.to_param}".downcase
  end

  def next_playlist_ids_url(document)
    total = document.xpath('/rss/channel/openSearch:totalResults').inner_text.to_i
    start_index = document.xpath('/rss/channel/openSearch:startIndex').inner_text.to_i
    per_page = document.xpath('/rss/channel/openSearch:itemsPerPage').inner_text.to_i
    playlist_ids_url(start_index + per_page) unless (start_index + per_page) > total
  end
end
class YoutubePlaylistVideosParser
  include YoutubeVideosParser

  def initialize(playlist_id)
    @playlist_id = playlist_id
  end

  def each_item
    document_url = playlist_videos_url
    while document_url do
      doc = feed_document(document_url)
      doc.xpath("//#{FEED_ELEMENTS[:item]}").each do |item|
        yield parse_item(item)
      end
      document_url = next_playlist_videos_url(doc)
    end
  end

  private

  def playlist_videos_url(start_index = 1)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:'max-results'] = MAX_RESULTS_PER_FEED
    url_params[:'start-index'] = start_index
    "http://gdata.youtube.com/feeds/api/playlists/#{@playlist_id}?#{url_params.to_param}"
  end

  def next_playlist_videos_url(document)
    total = document.xpath('/rss/channel/openSearch:totalResults').inner_text.to_i
    start_index = document.xpath('/rss/channel/openSearch:startIndex').inner_text.to_i
    per_page = document.xpath('/rss/channel/openSearch:itemsPerPage').inner_text.to_i
    playlist_videos_url(start_index + per_page) unless (start_index + per_page) > total
  end
end
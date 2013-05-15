class YoutubeUploadedVideosParser
  include YoutubeVideosParser

  MAX_UPLOADED_VIDEO_COUNT = 1000.freeze

  def initialize(username)
    @username = username
  end

  def each_item
    document_url = uploaded_videos_url(@username)
    while document_url do
      doc = feed_document(document_url)
      doc.xpath("//#{FEED_ELEMENTS[:item]}").each do |item|
        yield parse_item(item)
      end
      document_url = next_uploaded_videos_url(@username, doc)
    end
  end

  def uploaded_videos_url(username, start_index = 1)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = username
    url_params[:'max-results'] = MAX_RESULTS_PER_FEED
    url_params[:orderby] = 'published'
    url_params[:'start-index'] = start_index
    "http://gdata.youtube.com/feeds/api/videos?#{url_params.to_param}".downcase
  end

  def next_uploaded_videos_url(username, document)
    total = document.xpath('/rss/channel/openSearch:totalResults').inner_text.to_i
    start_index = document.xpath('/rss/channel/openSearch:startIndex').inner_text.to_i
    per_page = document.xpath('/rss/channel/openSearch:itemsPerPage').inner_text.to_i
    uploaded_videos_url(username, start_index + per_page) if (start_index + per_page) <= [total, MAX_UPLOADED_VIDEO_COUNT].min
  end
end

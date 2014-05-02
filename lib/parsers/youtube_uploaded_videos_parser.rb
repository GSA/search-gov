class YoutubeUploadedVideosParser
  include YoutubeDocumentFetcher
  include YoutubeVideosParser

  def initialize(username)
    @username = username.freeze
  end

  protected

  def document_url(start_index = 1)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = @username
    url_params[:'max-results'] = MAX_RESULTS_PER_FEED
    url_params[:orderby] = 'published'
    url_params[:'start-index'] = start_index
    "http://gdata.youtube.com/feeds/api/videos?#{url_params.to_param}".downcase
  end
end

class GoogleImageSearch < GoogleSearch
  protected

  def params
    super.merge(searchType: 'image')
  end

  def process_results(response)
    image_results = response.items || []
    image_results.collect do |result|
      Hashie::Rash.new(title: result.title, width: result.image.width, height: result.image.height, file_size: result.image.byte_size,
                       content_type: result.mime, url: result.link, display_url: result.display_link, media_url: result.link,
                       thumbnail: {url: result.image.thumbnail_link, width: result.image.thumbnail_width, height: result.image.thumbnail_height})
    end
  end

end
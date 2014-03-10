module UrlStatusCodeFetcher
  def self.fetch(urls, &block)
    urls = [urls] if urls.is_a?(String)
    responses = {}
    Curl::Multi.get urls, method: :head do |easy|
      if block_given?
        yield easy.url, easy.status
      else
        responses[easy.url] = easy.status
      end
    end
    responses unless block_given?
  end
end

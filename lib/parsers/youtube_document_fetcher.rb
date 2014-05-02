module YoutubeDocumentFetcher
  MAX_RETRY_ATTEMPTS = 3.freeze
  RETRY_INTERVAL = 18.minutes.freeze

  def fetch_document(url)
    num_attempts = 0
    begin
      num_attempts += 1
      Nokogiri::XML(YoutubeConnection.get(url))
    rescue YoutubeConnection::QuotaError => error
      if num_attempts <= MAX_RETRY_ATTEMPTS
        sleep RETRY_INTERVAL
        retry
      else
        raise error
      end
    end
  end
end

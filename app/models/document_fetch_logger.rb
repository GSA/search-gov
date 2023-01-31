class DocumentFetchLogger
  attr_reader :attributes
  attr_reader :type
  attr_reader :url

  def initialize(url, type, attributes = { })
    @url = url
    @type = type
    @attributes = attributes
  end

  def log
    Rails.logger.info("[Document Fetch] #{log_info.to_json}")
  end

  private

  def log_info
    attributes.merge({
      domain: domain,
      time: time,
      type: type,
      url: url,
    })
  end

  def domain
    UrlParser.normalize_host(url)
  end

  def time
    Time.now.utc.to_fs(:db)
  end
end

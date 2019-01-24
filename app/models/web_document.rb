class WebDocument
  attr_reader :document, :url

  def initialize(document:, url:)
    @document = document
    @url = url
  end

  def parsed_content
    @parsed_content ||= parse_content
  end

  def metadata
    @metadata ||= extract_metadata
  end

  def language
    @language ||= extract_language&.downcase
  end

  def created
    timestamp(extract_created)
  end

  def changed
    timestamp(extract_changed.presence) || created
  end

  def noindex?
    false
  end

  def redirect_url
    nil
  end

  private

  def parse_content
    #implemented by subclasses
  end

  def extract_metadata
    #implemented by subclasses
  end

  def extract_language
    #implemented by subclasses
  end

  def extract_changed
    #implemented by subclasses
  end

  def detect_language
    detector = CLD3::NNetLanguageIdentifier.new(0, 1000)
    detected = detector.find_language(parsed_content)
    detected[:reliable?] ? detected[:language].to_s : nil
  end

  def timestamp(timestamp)
    Time.parse(timestamp)
  rescue ArgumentError, TypeError
    nil
  end
end

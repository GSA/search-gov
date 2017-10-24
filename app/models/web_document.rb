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
    @language ||= extract_language
  end

  def noindex?
    false
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

  def detect_language
    detected = CLD.detect_language(parsed_content)
    detected[:reliable] ? detected[:code] : nil
  end
end

class WebDocument
  attr_reader :document, :url

  def initialize(document:, url:)
    @document = document
    @url = url
  end
end

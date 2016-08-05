# coding: utf-8
class GoogleWebSearch < GoogleSearch
  protected

  def process_results(response)
    web_results = response.items || []
    coder = HTMLEntities.new
    processed = web_results.collect do |result|
      title = enable_highlighting ? convert_highlighting(coder.decode(result.html_title)) : result.title
      content = enable_highlighting ? convert_highlighting(strip_br_tags(coder.decode(result.html_snippet))) : result.snippet
      mashify title, result.link, content
    end
    processed.compact
  end

  def mashify(title, unescaped_url, content)
    Hashie::Rash.new({title: title, unescaped_url: unescaped_url, content: content})
  end

  private

  def strip_br_tags(str)
    str.gsub(/<\/?br>/, '')
  end

  def convert_highlighting(str)
    str.gsub(/\u003cb\u003e/, "\uE000").gsub(/\u003c\/b\u003e/, "\uE001")
  end
end
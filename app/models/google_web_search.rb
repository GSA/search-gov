# coding: utf-8
class GoogleWebSearch < GoogleSearch
  protected

  def process_results(response)
    web_results = response.items || []
    processed = web_results.collect do |result|
      title = enable_highlighting ? convert_highlighting(CGI::unescape_html(result.html_title)) : result.title
      content = enable_highlighting ? convert_highlighting(strip_br_tags(CGI::unescape_html(result.html_snippet))) : result.snippet
      if title.present?
        Hashie::Rash.new({title: title, unescaped_url: result.link, content: content})
      else
        nil
      end
    end
    processed.compact
  end

  private

  def strip_br_tags(str)
    str.gsub(/<\/?br>/,'')
  end

  def convert_highlighting(str)
    str.gsub(/\u003cb\u003e/, "\uE000").gsub(/\u003c\/b\u003e/, "\uE001")
  end

end
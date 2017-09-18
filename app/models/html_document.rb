class HtmlDocument < WebDocument
  attr_accessor :html

  def html
    @html ||= Nokogiri::HTML(document)
  end

  def title
    html.title.try(:strip) || url
  end

  def description
    metadata['description']
  end

  def parsed_content
    remove_scripts_and_styles
    extract_body
  end

  def language
    html_attributes['lang'].try(:content).first(2)
  end

  def keywords
    metadata['keywords']
  end

  private

  def remove_scripts_and_styles
    html.css('script').each(&:remove)
    html.css('style').each(&:remove)
  end

  def scrub_inner_text(inner_text)
    inner_text.gsub(/ /, ' ').squish.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').gsub('&amp;', '&').squish
  end

  def extract_body
    scrub_inner_text(Sanitize.clean(html.at('body').inner_html.encode('utf-8'))) rescue ''
  end

  def html_attributes
    html.at('//html').attributes
  end

  def metadata
    metadata = {}
    meta_nodes = html.xpath('//meta')
    meta_nodes.each do |node|
      metadata[node['name']] = node['content'] if node['name']
      metadata[node['property']] = node['content'] if node['property']
    end
    metadata
  end
end

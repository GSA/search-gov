class HtmlDocument < WebDocument
  include RobotsTaggable
  attr_accessor :html

  def html
    @html ||= Nokogiri::HTML(document)
  end

  def title
    metadata['og:title'] || html.title.try(:strip) || url
  end

  def description
    metadata['og:description'] || metadata['description']
  end

  def keywords
    metadata['keywords']
  end

  def created
    metadata['article:published_time']
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

  def extract_metadata
    metadata = {}
    meta_nodes = html.xpath('//meta')
    meta_nodes.each do |node|
      (metadata[node['name'].downcase] = node['content']) if node['name']
      (metadata[node['property'].downcase] = node['content']) if node['property']
    end
    metadata
  end

  def parse_content
    remove_scripts_and_styles
    extract_body
  end

  def extract_language
    html_attributes['lang'].try(:content).try(:first, 2) || detect_language
  end

  def robots_directives
    (metadata['robots'] || '').downcase.split(',').map(&:strip)
  end
end

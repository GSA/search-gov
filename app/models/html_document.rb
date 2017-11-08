class HtmlDocument < WebDocument
  include RobotsTaggable

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

  def html
    @html ||= Loofah.document(document)
  end

  def parse_content
    # This method is a descendent of the rudimentary parsing done in IndexedDocument.
    # If we eventually need to get fancier, we might consider swapping this out
    # for a gem such as Html2Text.
    plain_text = html.scrub!(:whitewash).to_text(encode_special_chars: false).encode('utf-8')
    plain_text.gsub(/[ \t]+/,' ' ).gsub(/[\n\r]+/, "\n").chomp.lstrip
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

  def extract_language
    html_attributes['lang'].try(:content).try(:first, 2) || detect_language
  end

  def robots_directives
    (metadata['robots'] || '').downcase.split(',').map(&:strip)
  end
end

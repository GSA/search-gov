# frozen_string_literal: true

class HtmlDocument < WebDocument
  include RobotsTaggable

  def title
    titles = [metadata['og:title']&.first, html.title.try(:strip)]
    titles.compact_blank!
    titles.blank? ? url : titles.max_by(&:length)
  end

  def description
    metadata['og:description']&.first || metadata['description']&.first || dublin_core_data['dc.description']&.first
  end

  def keywords
    extract_keywords.uniq.compact.join(', ')
  end

  def audience
    dcterms_data['dcterms.audience']&.first
  end

  def image_url
    metadata['og:image']&.first
  end

  def content_type
    [dublin_core_data['dc.type'], dcterms_data['dcterms.type'], metadata['og:type']].uniq.compact.join(', ')
  end

  def searchgov_custom(number)
    return if !number.is_a?(Integer) || !number.between?(1, 3)

    metadata["searchgov_custom#{number}"]&.first
  end

  # Returns client-side redirect url
  def redirect_url
    refresh = html.css('meta[http-equiv]').detect { |node| /refresh/i === node['http-equiv'] }
    if refresh
      match_data = refresh['content'].match(/.*URL=['"]?(?<path>[^'"]*)/i)
      return nil if match_data.nil?

      new_path = match_data[:path]
      URI.join(url, Addressable::URI.encode(new_path)).to_s
    end
  end

  private

  def html
    @html ||= Loofah.document(document.dup.force_encoding('UTF-8').
                              encode('UTF-8', invalid: :replace,
                                              undef: :replace,
                                              replace: '').gsub(%r{</?td[^>]*>\n?}i, ' '))
  end

  def parse_content
    # This method is a descendent of the rudimentary parsing done in IndexedDocument.
    # If we eventually need to get fancier, we might consider swapping this out
    # for a gem such as Html2Text.
    # And if you're wondering why we're generating a Loofah document, converting
    # it to html, then running it through Loofah again, it's because Loofah's 'to_text' method is
    # much smarter about whitespace than Nokogiri, but you can't run `to_text` on the Nokogiri
    # elements extracted by "html.at('main')". Hence the jumping through hoops.
    plain_text = Loofah.fragment(main_html).
      scrub!(tag_scrubber).
      scrub!(:whitewash).
      to_text(encode_special_chars: false)
    plain_text.gsub(/[ \t]+/, ' ').gsub(/[\n\r]+/, "\n").chomp.lstrip
  end

  def tag_scrubber
    Loofah::Scrubber.new do |node|
      # convert custom tags to plain 'ol divs to ensure they are not
      # stripped out during HTML sanitization
      node.name = 'div' if /-/.match?(node.name)

      # omit common elements
      node.remove if %w[footer nav].include?(node.name)
    end
  end

  def html_attributes
    html.at('//html').attributes
  end

  def extract_metadata
    metadata = {}
    meta_nodes = html.xpath('//meta')
    meta_nodes.each do |node|
      property = node['name'] || node['property']
      (metadata[property.downcase] ||= []) << node['content'] unless property.nil?
    end
    metadata
  end

  def extract_keywords
    [dublin_core_data['dc.subject'],
     dcterms_data['dcterms.subject'],
     dcterms_data['dcterms.keywords'],
     metadata['keywords'],
     metadata['article:tag'],
     metadata['article:section']].map { |k| k&.join(', ') }
  end

  def extract_language
    html_attributes['lang']&.content
  end

  def extract_created
    metadata['article:published_time']&.first || dublin_core_date || dcterms_date
  end

  def extract_changed
    metadata['article:modified_time']&.first
  end

  def robots_directives
    (metadata['robots']&.first || '').downcase.split(',').map(&:strip)
  end

  def main_html
    [html.at('main'), html.at_css('[role="main"]'), html.at('body'), html].find do |element|
      element&.text.present?
    end&.to_html
  end

  def dublin_core_date
    dublin_core_data['dc.date']&.first || dublin_core_data['dc.date.created']&.first
  end

  def dcterms_date
    dcterms_data['dcterms.created']&.first
  end

  def dublin_core_data
    metadata.select { |k, _v| /^dc\./.match?(k) }
  end

  def dcterms_data
    metadata.select { |k, _v| /^dcterms\./.match?(k) }
  end
end

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
    @html ||= Loofah.document(document.encode('UTF-8', { invalid: :replace,
                                                         undef: :replace,
                                                         replace: '' }))
  end

  def parse_content
    # This method is a descendent of the rudimentary parsing done in IndexedDocument.
    # If we eventually need to get fancier, we might consider swapping this out
    # for a gem such as Html2Text.
    # And if you're wondering why we're generating a Loofah document, converting
    # it to html, then running it through Loofah again, it's because Loofah's 'to_text' method is
    # much smarter about whitespace than Nokogiri, but you can't run `to_text` on the Nokogiri
    # elements extracted by "html.at('main')". Hence the jumping through hoops.
    main_html = ( html.at('main') || html.at_css('[role="main"]') || html.at('body') || html ).to_html
    plain_text = Loofah.fragment(main_html).scrub!(:whitewash).to_text(encode_special_chars: false)
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

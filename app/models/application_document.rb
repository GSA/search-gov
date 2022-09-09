class ApplicationDocument < WebDocument
  def title
    metadata['dc:title'].presence ? [metadata['dc:title']].flatten.max_by(&:length) : File.basename(url)
  end

  def description
    metadata['pdf:docinfo:subject'] || parse_description
  end

  def keywords
    metadata['pdf:docinfo:keywords'] || metadata['meta:keyword']
  end

  private

  def extract_metadata
    Tika.get_recursive_metadata(document).first
  end

  def parse_content
    content = metadata['X-TIKA:content'] || ''
    content.gsub!(/\n+/, "\n")
    content.tr("\uFFFD", ' ')&.squish
  end

  def extract_language
    metadata['language']
  end

  def extract_created
    metadata['dcterms:created']
  end

  def extract_changed
    metadata['dcterms:modified']
  end

  def parse_description
    return unless metadata['dc:subject'] && metadata['meta:keyword']

    desc = metadata['dc:subject'] - [metadata['meta:keyword']]
    desc.first
  end
end

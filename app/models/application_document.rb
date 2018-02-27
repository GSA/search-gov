class ApplicationDocument < WebDocument
  def title
    metadata['title'].presence ? [metadata['title']].flatten.max_by(&:length) : File.basename(url)
  end

  def description
    metadata['subject']
  end

  def keywords
    metadata['Keywords']
  end

  def created
    metadata['Creation-Date']
  end

  private

  def extract_metadata
    Tika.get_recursive_metadata(document).first
  end

  def parse_content
    metadata['X-TIKA:content']&.gsub(/\uFFFD/, ' ')&.squish
  end

  def extract_language
    language = metadata['language'] || ''
    language[/^(?<code>[a-z]{2})\W?/,"code"] ||
      Language.find_by_name(language)&.code ||
      detect_language
  end
end

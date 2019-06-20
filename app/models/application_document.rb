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
    metadata['Creation-Date']
  end

  def extract_changed
    metadata['Last-Modified']
  end
end

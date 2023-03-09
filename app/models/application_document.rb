# frozen_string_literal: true

class ApplicationDocument < WebDocument
  def title
    if metadata['dc:title'].presence
      [metadata['dc:title']].flatten.max_by(&:length)
    else
      File.basename(url)
    end
  end

  def description
    metadata['pdf:docinfo:subject'] || parse_description
  end

  def keywords
    metadata['pdf:docinfo:keywords'] || metadata['meta:keyword']
  end

  def audience
    nil
  end

  def content_type
    nil
  end

  def thumbnail_url
    nil
  end

  def searchgov_custom(_number)
    nil
  end

  private

  def extract_metadata
    Tika.get_recursive_metadata(document).first
  end

  def parse_content
    content = metadata['X-TIKA:content']
    return '' unless content&.match?(/([a-zA-Z])|\d/)

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
    # We may be able to clean this up once Tika has updated their
    # metadata parsing: https://issues.apache.org/jira/browse/TIKA-3629
    return unless metadata['dc:subject'] && metadata['meta:keyword']

    description = [metadata['dc:subject']].flatten - [metadata['meta:keyword']]
    description.first
  end
end

module RssFeedParser
  def extract_published_at(pub_date_paths, item)
    published_at = nil
    pub_date_paths.each do |pub_date_path|
      published_at_str = item.xpath(pub_date_path).inner_text
      next if published_at_str.blank?
      published_at = DateTime.parse published_at_str
      break if published_at.present?
    end
    published_at
  end
end

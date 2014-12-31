module RssFeedParser
  VALID_YEAR_RANGE = (1000..9999).freeze

  def extract_published_at(item, *pub_date_paths)
    published_at = nil
    pub_date_paths.each do |pub_date_path|
      published_at_str = item.xpath(pub_date_path).inner_text
      next if published_at_str.blank?
      published_at = parse_datetime published_at_str
      break if published_at.present?
    end
    published_at
  end

  def parse_datetime(datetime_str)
    datetime = DateTime.parse datetime_str
    datetime if datetime && VALID_YEAR_RANGE.include?(datetime.year)
  end
end

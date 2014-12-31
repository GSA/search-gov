module QuerySanitizer
  def self.sanitize(query)
    Sanitize.clean(query.to_s).gsub('&amp;', '&').squish if query
  rescue ArgumentError => e
    nil
  end
end
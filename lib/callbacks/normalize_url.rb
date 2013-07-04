class NormalizeUrl
  def initialize(*attributes)
    @attributes = attributes
  end

  def before_validation(record)
    @attributes.each do |attr|
      url = record.send(attr.to_sym)
      next if url.blank?
      normalized_url = UrlParser.normalize url
      record.send("#{attr}=", normalized_url) if normalized_url
    end
  end
end

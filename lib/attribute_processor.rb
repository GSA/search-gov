module AttributeProcessor
  def self.prepend_attributes_with_http(record, *url_attribute_names)
    url_attribute_names.each do |attr_name|
      value = record.send :"#{attr_name}"

      if value.present? && value !~ %r{^https?://}i
        record.send :"#{attr_name}=", "http://#{value.strip}"
      end
    end
  end

  def self.sanitize_attributes(record, *attribute_names)
    attribute_names.each do |attr_name|
      value = record.send :"#{attr_name}"
      record.send :"#{attr_name}=", Sanitize.clean(value)
    end
  end

  def self.squish_attributes(record, *attribute_names)
    options = attribute_names.extract_options!
    assign_nil_on_blank = options[:assign_nil_on_blank]

    attribute_names.each do |attr_name|
      value = record.send :"#{attr_name}"
      squished_value = value.gsub(/[[:space:]]/, ' ').squish if value

      if squished_value.blank? && assign_nil_on_blank
        record.send :"#{attr_name}=", nil
      else
        record.send :"#{attr_name}=", squished_value
      end
    end
  end
end


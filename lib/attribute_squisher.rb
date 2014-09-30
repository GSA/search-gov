# inspired from https://github.com/holli/auto_strip_attributes/blob/master/lib/auto_strip_attributes.rb
module AttributeSquisher
  def before_validation_squish(*attr_names)
    options = attr_names.extract_options!
    assign_nil_on_blank = options[:assign_nil_on_blank]

    before_validation do |record|
      attr_names.each do |attr_name|
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
end

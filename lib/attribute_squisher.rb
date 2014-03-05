# inspired from https://github.com/holli/auto_strip_attributes/blob/master/lib/auto_strip_attributes.rb
module AttributeSquisher
  def before_validation_squish(*attr_names)
    options = attr_names.extract_options!
    assign_nil_on_blank = options[:assign_nil_on_blank]

    before_validation do |record|
      attr_names.each do |attr_name|
        value = record[attr_name]
        if value.present?
          record[attr_name] = value.squish
        elsif assign_nil_on_blank
          record[attr_name] = nil
        end
      end
    end
  end
end

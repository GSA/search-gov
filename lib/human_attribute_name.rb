module HumanAttributeName
  def human_attribute_name(attribute_key_name, _options = {})
    human_attribute_name_hash[attribute_key_name.to_sym] || super
  end
end


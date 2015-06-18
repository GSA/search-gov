module ActiveRecordExtension
  def swap_error_key(from, to)
    errors.add(to, errors.delete(from)) if errors.include?(from)
  end

  def destroy_on_blank(attributes, *keys)
    attributes.each do |attribute|
      item = attribute[1]
      item[:_destroy] = true if keys.all? { |key| item[key].blank? }
    end
  end
end

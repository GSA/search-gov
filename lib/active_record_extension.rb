module ActiveRecordExtension
  def swap_error_key(from, to)
    errors.add(to, errors.delete(from)) if errors.include?(from)
  end

  def set_http_prefix(*fields)
    fields.each do |field|
      value = self.send(field.to_sym)
      self.send(:"#{field.to_s}=", "http://#{value.strip}") unless value.blank? or value =~ %r{^http(s?)://}i
    end
  end
end
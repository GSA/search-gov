module KeenScopedKey
  def self.generate(affiliate_id)
    data = { "filters" => [{ "property_name" => "affiliate_id", "operator" => "eq", "property_value" => affiliate_id }] }
    scoped_key = Keen::ScopedKey.new(Keen.master_key, data)
    scoped_key.encrypt!
  end
end

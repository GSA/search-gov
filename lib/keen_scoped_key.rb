module KeenScopedKey
  def self.generate(affiliate_id)
    raise ArgumentError, "Affiliate ID required" unless affiliate_id.present?
    data = { "filters" => [{ "property_name" => "affiliate_id", "operator" => "eq", "property_value" => affiliate_id }],
             "allowed_operations" => ["read"] }
    scoped_key = Keen::ScopedKey.new(Keen.master_key, data)
    scoped_key.encrypt!
  end
end

module URI
  def self.merge_unless_recursive(self_url, target_url)
    begin
      self_url.path.end_with?(target_url.path) ? nil : self_url.merge(target_url)
    rescue
      nil
    end
  end
end
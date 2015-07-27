module StringProcessor
  def self.strip_highlights(str)
    str.tr("\uE000\uE001", '') if str
  end
end

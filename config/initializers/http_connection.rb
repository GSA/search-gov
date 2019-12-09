module HttpConnection
  def self.get(url)
    f = URI.parse(url).open
    begin
      f.read
    ensure
      f.is_a?(Tempfile) ? f.close(true) : f.close
    end
  end
end

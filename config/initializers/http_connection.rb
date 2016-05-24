module HttpConnection
  def self.get(url)
    f = Kernel.open(url, 'Accept-Encoding' => 'None')
    begin
      f.read
    ensure
      f.is_a?(Tempfile) ? f.close(true) : f.close
    end
  end
end

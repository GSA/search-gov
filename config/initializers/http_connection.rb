module HttpConnection
  def self.get(url)
    if url =~ %r[https?://gdata\.youtube\.com/]i
      YoutubeConnection.get(url)
    else
      f = Kernel.open(url)
      begin
        f.read
      ensure
        f.is_a?(Tempfile) ? f.close(true) : f.close
      end
    end
  end
end
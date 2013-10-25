require 'addressable/uri'

module UrlParser
  def self.normalize(url)
    url = "http://#{url}" unless url =~ %r{^https?://}i
    normalize_non_query_parts url
  end

  def self.shorten_url(url, length = 42)
    if url.length <= length
      if url =~ /^http:\/\/[-a-zA-Z0-9.]+\//i
        if url.last == '/'
          url[7..-2]
        else
          url[7..-1]
        end
      else
        url
      end
    elsif url.count('/') >= 3

      qx = url.index('?')

      if qx
        arr = url[0 .. qx - 1].split('/')
        q = ["?", url[qx + 1 .. -1].split('&').first, "..."].join
        if q.length > length + 3
          q = q[0...length] + "..."
        end
      else
        arr = url.split('/')
        q = ""
      end

      if arr[0] == "http:" && arr[2] =~ /^[-a-z0-9.]+$/i
        host = arr[2]
        keep_protocol = false
      else
        host = arr[0]+"//"+arr[2]
        keep_protocol = true
      end

      doc_path = arr[3..-1]

      doc = if doc_path.size == 0
              if q.empty? && !keep_protocol
                ""
              else
                "/"
              end
            else
              head = 0
              tail = doc_path.length - 1
              path_length = doc_path.last.length + 5

              if path_length >= length + 5
                path_length = length + 5
                doc_path[tail] = doc_path[tail][0...length] + "..."
              end
              path_max_length = length - (host.length + q.length)

              while head < tail && ((path_length + doc_path[head].length + 1) < path_max_length)
                path_length += doc_path[head].length + 1
                head += 1
                if head < tail && ((path_length + doc_path[tail-1].length + 1) < path_max_length)
                  tail -= 1
                  path_length += doc_path[tail].length + 1
                end
              end

              if head == tail
                "/" + doc_path.join("/")
              elsif head == 0
                "/" + "..." + "/" + doc_path[tail..-1].join("/")
              else
                "/" + doc_path[0..head-1].join("/") + "/.../"+ doc_path[tail..-1].join("/")
              end
            end
      host + doc + q
    else
      url[0, length] + "..."
    end
  end

  private

  def self.normalize_non_query_parts(uri)
    addressable_uri = Addressable::URI.parse uri rescue nil
    addressable_uri.host = addressable_uri.normalized_host
    addressable_uri.authority = addressable_uri.normalized_authority
    addressable_uri.path = addressable_uri.normalized_path.gsub(/\/+/, '/')
    addressable_uri.fragment = nil
    addressable_uri.to_s
  rescue
    nil
  end
end

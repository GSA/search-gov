# frozen_string_literal: true

# Fixes double-slash ("//") URL construction in the elasticsearch-ruby transport.
#
# Two sources of "//":
# 1. host[:path] is "/" or "" (truthy in Ruby) combined with the "/" prefix
#    before the API path, producing "host:port//"
# 2. API paths starting with "/" (e.g. NewRelic's cluster name check sends
#    perform_request('GET', '/')) get an extra "/" prepended
#
# Can be removed if/when the GSA fork of elasticsearch-ruby is updated to
# handle this: https://github.com/GSA/elasticsearch-ruby (branch 7.4)

module ElasticsearchTransportUrlFix
  module ConnectionPatch
    def full_url(path, params = {})
      url  = "#{host[:protocol]}://"
      url += "#{CGI.escape(host[:user])}:#{CGI.escape(host[:password])}@" if host[:user]
      url += "#{host[:host]}:#{host[:port]}"
      url += host[:path].to_s.chomp('/')
      fp = full_path(path, params)
      url += fp.start_with?('/') ? fp : "/#{fp}"
    end
  end

  module BasePatch
    private

    def __full_url(host)
      url  = "#{host[:protocol]}://"
      url += "#{CGI.escape(host[:user])}:#{CGI.escape(host[:password])}@" if host[:user]
      url += "#{host[:host]}"
      url += ":#{host[:port]}" if host[:port]
      url += host[:path].to_s.chomp('/')
      url
    end
  end

  module ClientPatch
    private

    def __parse_host(host)
      host_parts = super
      if host_parts[:path]
        host_parts[:path].chomp!('/')
        host_parts[:path] = nil if host_parts[:path].empty?
      end
      host_parts
    end
  end
end

Elasticsearch::Transport::Transport::Connections::Connection.prepend(
  ElasticsearchTransportUrlFix::ConnectionPatch
)
Elasticsearch::Transport::Transport::Base.prepend(
  ElasticsearchTransportUrlFix::BasePatch
)
Elasticsearch::Transport::Client.prepend(
  ElasticsearchTransportUrlFix::ClientPatch
)

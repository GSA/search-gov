# frozen_string_literal: true

module ConnectionsHelper
  def link_to_add_new_connection(title, site)
    instrumented_link_to title, new_connection_site_display_path(site), site.connections.length, 'connection'
  end
end

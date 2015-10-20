module WatcherDSL
  def query_blocklist_filter(query_blocklist)
    json.child! do
      json.terms do
        json.raw query_blocklist.split(',').map { |term| term.strip.downcase }
      end
    end if query_blocklist.present?

  end
end

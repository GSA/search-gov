module GeoipLookup
  def self.establish_connection!
    @geoip_db = GeoIP.new("#{Rails.root}/db/geoip/geoip.dat")
  end

  def self.lookup(ip)
    @geoip_db.city(ip)
  rescue SocketError => e
    Rails.logger.warn "GeoipLookup failed lookup on #{ip}", e
    nil
  end
end

GeoipLookup.establish_connection!
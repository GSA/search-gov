class SiteCtrStat
  attr_reader :site_id, :display_name, :historical, :recent

  def initialize(site, historical, recent)
    @site_id = site.id
    @display_name = site.display_name
    @historical, @recent = historical, recent
  end

end
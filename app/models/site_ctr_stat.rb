class SiteCtrStat
  attr_reader :site_name, :display_name, :historical, :recent

  def initialize(site, historical, recent)
    @site_name = site.name
    @display_name = site.display_name
    @historical, @recent = historical, recent
  end

end
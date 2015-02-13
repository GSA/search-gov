class SearchModuleCtrStat
  attr_reader :name, :tag, :historical, :recent

  def initialize(name, tag, historical, recent)
    @name, @tag, @historical, @recent = name, tag, historical, recent
  end

end
class ElasticBoostedContentQuery < ElasticBestBetQuery
  def initialize(options)
    super(options)
    self.highlighted_fields = %w(title description)
  end
end
module LogstashPrefix

  private
  def logstash_prefix(filter_bots)
    filter_bots ? "human-logstash-" : "logstash-"
  end
end

class WatcherTopNMissingQuery < TopNMissingQuery
  def initialize(watcher, agg_options = {})
    super(watcher.affiliate.name, agg_options)
    @watcher = watcher
  end

  def additional_musts(json)
    #TODO: compute since_when
    json.child! { since(json, since_when) }
  end

  def additional_must_nots(json)
    json.child! do
      json.terms do
        #TODO: split&trim&downcase blocked terms
        json.raw []
      end
    end
  end

end
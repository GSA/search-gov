class WatcherTopNMissingQuery < TopNMissingQuery
  def initialize(no_results_watcher, agg_options = {})
    super(no_results_watcher.affiliate.name, agg_options)
    @no_results_watcher = no_results_watcher
  end

  def additional_musts(json)
    json.child! { date_range(json, "{{ctx.trigger.scheduled_time}}||-#{@no_results_watcher.time_window}", "{{ctx.trigger.scheduled_time}}") }
  end

  def additional_must_nots(json)
    json.child! do
      json.terms do
        json.raw query_blocklist
      end
    end if @no_results_watcher.query_blocklist.present?
  end

  private

  def query_blocklist
    @no_results_watcher.query_blocklist.split(',').map { |term| term.strip.downcase }
  end

end
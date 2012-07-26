if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # ... set MultiDb configuration options, if any ...
      MultiDb::ConnectionProxy.setup!
    end
  end
end
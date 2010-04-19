if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # ... set MultiDb configuration options, if any ...
      MultiDb::ConnectionProxy.setup!
      Rails.cache.instance_variable_get(:@data).reset
      Rails.cache.instance_variable_get(:@data).silence!      
    end
  end
end
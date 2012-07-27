# Include hook code here
require Rails.root.to_s + "/config/extras/google_visualization/google_visualization"
ActionView::Base.send :include, GoogleVisualization::Helpers

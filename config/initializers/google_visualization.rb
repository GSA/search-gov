# Include hook code here
require Rails.root.to_s + "/lib/google_visualization/google_visualization"
ActionView::Base.send :include, GoogleVisualization::Helpers

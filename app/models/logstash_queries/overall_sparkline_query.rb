# frozen_string_literal: true

class OverallSparklineQuery < ModuleSparklineQuery
  def top_level_histogram_agg(json)
    histogram_type_agg(json)
  end
end

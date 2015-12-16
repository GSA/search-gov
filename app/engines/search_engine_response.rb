class SearchEngineResponse
  attr_accessor :spelling_suggestion,
                :results,
                :start_record,
                :end_record,
                :total,
                :tracking_information,
                :diagnostics
  def initialize
    yield self if block_given?
    diagnostics = {}
  end
end

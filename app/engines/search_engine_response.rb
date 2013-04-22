class SearchEngineResponse
  attr_accessor :spelling_suggestion,
                :results,
                :start_record,
                :end_record,
                :total
  def initialize
    yield self
  end
end
class AbstractEngine
  attr_accessor :total, :results, :startrecord, :endrecord, :related_search

  def initialize(options)
    @query, @page, @affiliate, @results, @related_search = options[:query], options[:page], options[:affiliate], [], []
  end
end
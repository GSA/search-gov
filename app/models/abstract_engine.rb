class AbstractEngine
  attr_accessor :total, :results, :startrecord, :endrecord

  def initialize(options)
    @query, @page, @affiliate = options[:query], options[:page], options[:affiliate]
  end
end
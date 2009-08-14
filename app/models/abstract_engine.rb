class AbstractEngine
  attr_accessor :total, :results, :startrecord, :endrecord

  def initialize(options)
    @query, @page = options[:query], options[:page]
  end
end
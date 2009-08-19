class Search
  ENGINES = {:gweb => Gweb, :gss => Gss}
  attr_accessor :query, :page, :error_message, :engine, :affiliate
  TOO_LONG = "That is too long a word. Try using a shorter word."
  MAX_QUERYTERM_LENGTH = 1000

  def initialize(options = {})
    options ||= {}
    self.query = options[:query] || ''
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    klass = ENGINES[options[:engine].to_sym] rescue Gweb
    self.engine = klass.new(:query => self.query, :page => self.page, :affiliate => self.affiliate)
  end

  def run
    self.error_message = TOO_LONG and return false if self.query.length > MAX_QUERYTERM_LENGTH
    self.engine.run
  end

  def total
    self.engine.total
  end

  def startrecord
    self.engine.startrecord
  end

  def endrecord
    self.engine.endrecord
  end

  def results
    self.engine.results || []
  end

  def per_page
    self.engine.class::DEFAULT_PER_PAGE
  end

end


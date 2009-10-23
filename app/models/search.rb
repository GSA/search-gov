class Search
  ENGINES = {:bing=> Bing}
  attr_accessor :query, :page, :error_message, :engine, :affiliate
  MAX_QUERYTERM_LENGTH = 1000

  def initialize(options = {})
    options ||= {}
    self.query = options[:query] || ''
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    klass = ENGINES[options[:engine].to_sym] rescue Bing
    self.engine = klass.new(:query => self.query, :page => self.page, :affiliate => self.affiliate)
  end

  def run
    self.error_message = (I18n.translate :too_long) and return false if self.query.length > MAX_QUERYTERM_LENGTH
    self.error_message = (I18n.translate :empty_query) and return false if self.query.blank?
    self.engine.run
  end

  def per_page
    self.engine.class::DEFAULT_PER_PAGE
  end

  %w{total startrecord endrecord results related_search spelling_suggestion images}.each {|fn| class_eval "def #{fn}; self.engine.#{fn}; end" }
end
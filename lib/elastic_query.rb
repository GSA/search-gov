class ElasticQuery
  include QueryPreprocessor

  DEFAULT_SIZE = 10.freeze
  MAX_SIZE = 100.freeze
  attr_reader :offset, :size, :sort
  attr_accessor :highlighted_fields

  def initialize(options)
    options.reverse_merge!(size: DEFAULT_SIZE)
    @offset = options[:offset].to_i
    @size = [options[:size].to_i, MAX_SIZE].min
    @q = preprocess(options[:q]) if options[:q].present?
    @highlighting = !(options[:highlighting] == false)
  end

  def body
    Jbuilder.encode do |json|
      query(json)
      highlight(json) if @highlighting
    end
  end

  def multi_match(json, fields, query, options = {})
    json.multi_match do
      json.fields fields
      json.query query
      options.each do |option, value|
        json.set! option, value
      end
    end
  end

  def highlight(json)
    json.highlight do
      json.pre_tags %w(<strong>)
      json.post_tags %w(</strong>)
      highlight_fields(json)
    end if self.highlighted_fields.present?
  end

  def highlight_fields(json)
    json.fields do
      self.highlighted_fields.each do |field|
        json.set! field, { number_of_fragments: 0 }
      end
    end
  end

end

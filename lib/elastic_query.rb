# frozen_string_literal: true

class ElasticQuery

  DEFAULT_SIZE = 10.freeze
  MAX_SIZE = 100.freeze
  DEFAULT_PRE_TAGS = %w(<strong>).freeze
  DEFAULT_POST_TAGS = %w(</strong>).freeze
  attr_reader :offset, :size, :sort
  attr_accessor :text_fields, :language

  def initialize(options)
    options.reverse_merge!(size: DEFAULT_SIZE)
    @offset = options[:offset].to_i
    @size = [options[:size].to_i, MAX_SIZE].min
    @q = options[:q]
    @highlighting = !(options[:highlighting] == false)
    @language = options[:language]
    @text_analyzer = "#{options[:language]}_analyzer"
    @sort = options[:sort]
    @pre_tags = options[:pre_tags]
    @post_tags = options[:post_tags]
  end

  def body
    Jbuilder.encode do |json|
      query(json)
      highlight(json) if @highlighting
      yield json if block_given?
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
      json.pre_tags pre_tags
      json.post_tags post_tags
      highlight_fields(json)
    end if self.highlighted_fields.present?
  end

  def pre_tags
    @pre_tags || default_pre_tags
  end

  def default_pre_tags
    DEFAULT_PRE_TAGS
  end

  def post_tags
    @post_tags || default_post_tags
  end

  def default_post_tags
    DEFAULT_POST_TAGS
  end

  def highlight_fields(json)
    json.fields do
      self.highlighted_fields.each do |field|
        json.set! field, { number_of_fragments: 0 }
      end
    end
  end

  def highlighted_fields
    @highlighted_fields ||= text_fields.map { |field| "#{field}.#{language}" }
  end
end

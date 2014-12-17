class ApiBlendedSearch < BlendedSearch
  include Api::V2::SearchAsJson

  HIGHLIGHT_OPTIONS = {
    pre_tags: ["\ue000"],
    post_tags: ["\ue001"]
  }.freeze

  attr_reader :next_offset

  def initialize(options = {})
    super(options.merge(HIGHLIGHT_OPTIONS))
    @next_offset_within_limit = options[:next_offset_within_limit]
  end

  def handle_response(response)
    super
    @next_offset = @offset + @limit if @next_offset_within_limit && more_results_available?
  end

  protected

  def result_hash_as_json(result)
    pub_date = result.published_at ? result.published_at.to_date : nil
    { title: result.title,
      url: result.url,
      snippet: build_snippet_as_json(result.description),
      pub_date: pub_date }
  end

  private

  def more_results_available?
    @total > (@offset + @limit)
  end
end

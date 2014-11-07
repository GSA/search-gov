class ApiBlendedSearch < BlendedSearch
  HIGHLIGHT_OPTIONS = {
    pre_tags: ["\ue000"],
    post_tags: ["\ue001"]
  }.freeze

  def initialize(options = {})
    super(options.merge(HIGHLIGHT_OPTIONS))
  end

  def as_json(options = {})
    hash = { web: { total: @total, results: results_to_hash } }
    hash[:text_best_bets] = boosted_contents ? boosted_contents.results : []
    hash[:graphic_best_bets] = featured_collections ? featured_collections.results : []
    hash[:related_search_terms] = related_search ? related_search : []
    hash
  end

  def results_to_hash
    @results.collect do |result|
      { title: result.title,
        url: result.url,
        snippet: build_snippet(result.description) }
    end
  end

  private

  def build_snippet(description)
    if description =~ /\uE000/
      description.sub!(/^([^A-Z<])/,'...\1')
    else
      description = description.truncate(150, separator: ' ')
    end
    description
  end
end

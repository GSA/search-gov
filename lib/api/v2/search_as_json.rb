module Api::V2::SearchAsJson
  def as_json(_options = {})
    hash = {}
    append_web_as_json hash
    append_govbox_set_as_json hash
    hash
  end

  def append_web_as_json(hash)
    web_hash = {
      next_offset: @next_offset,
      results: results_to_hash
    }
    web_hash[:total] = @total if @total
    hash[:web] = web_hash
  end

  def append_govbox_set_as_json(hash)
    hash[:text_best_bets] = boosted_contents ? boosted_contents.results : []
    hash[:graphic_best_bets] = featured_collections ? featured_collections.results : []
    hash[:related_search_terms] = related_search ? related_search : []
  end

  def results_to_hash
    @results.collect do |result|
      { title: result.title,
        url: result.url,
        snippet: build_snippet(result.description) }
    end
  end

  protected

  def build_snippet(description)
    if description =~ /\uE000/
      description.sub!(/^([^A-Z<])/, '...\1')
    else
      description = description.truncate(150, separator: ' ')
    end
    description
  end
end

# frozen_string_literal: true

class OpenSearch::DocumentQuery < SearchElastic::DocumentQuery
  private

  def parse_query(query)
    site_params_parser = OpenSearch::QueryParser.new(query)
    @site_filters = site_params_parser.site_filters
    @included_sites = @site_filters[:included_sites]
    @excluded_sites = @site_filters[:excluded_sites]
    @query = site_params_parser.stripped_query
  end
end

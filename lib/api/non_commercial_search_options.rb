# frozen_string_literal: true

class Api::NonCommercialSearchOptions < Api::SearchOptions
  attr_accessor :sort_by,
                :site_limits,
                :tags

  def initialize(params = {})
    super
    self.sort_by = params[:sort_by]
    self.site_limits = params[:site_limits]
    self.tags = params[:tags]
  end

  def attributes
    super.merge({ sort_by: sort_by,
                  site_limits: site_limits,
                  tags: tags })
  end
end

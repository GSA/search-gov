# frozen_string_literal: true

class Api::NonCommercialSearchOptions < Api::SearchOptions
  attr_accessor :sort_by,
                :tags

  def initialize(params = {})
    super
    self.sort_by = params[:sort_by]
    self.tags = params[:tags]
  end

  def attributes
    super.merge({ sort_by: sort_by,
                  tags: tags })
  end
end

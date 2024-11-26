# frozen_string_literal: true

class ApiI14ySearch < I14ySearch
  def initialize(options = {})
    super

    @highlight_options = options.slice(:pre_tags, :post_tags) || Api::V2::HighlightOptions::DEFAULT
  end
end

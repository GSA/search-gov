require 'github/markdown'

module Haml::Filters
  remove_filter 'Markdown'

  module Markdown
    include Haml::Filters::Base

    def render(text)
      ::GitHub::Markdown.render text
    end
  end
end

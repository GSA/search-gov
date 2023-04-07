require 'redcarpet'

module Haml::Filters
  remove_filter 'Markdown'

  module Markdown
    include Haml::Filters::Base

    def render(text)
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, tables: true)
      markdown.render(text)
    end
  end
end

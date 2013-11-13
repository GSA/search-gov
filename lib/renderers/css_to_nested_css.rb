module Renderers
  class CssToNestedCss
    AT_RULES_TO_REJECT = %w(@charset @import).freeze

    def initialize(parent_selector, css)
      @parent_selector = parent_selector
      @css = css
    end

    def render
      ::Renderers::Sass.new(render_nested_sass).render
    end

    private

    def render_nested_sass
      sass_values = [@parent_selector]
      original_sass_values = ::Sass::CSS.new(@css).render.split("\n")
      original_sass_values.reject! { |value| value =~ /^(#{AT_RULES_TO_REJECT.join('|')})/ }
      sass_values.push(original_sass_values.map { |value| "  #{value}" })
      sass_values.join("\n")
    end
  end
end

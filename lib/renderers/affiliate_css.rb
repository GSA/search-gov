module Renderers
  class AffiliateCss
    include AffiliateCssHelper

    # deprecated - legacy SERP
    DESKTOP_LOOK_AND_FEEL_TEMPLATE = File.open("#{Rails.root}/lib/renderers/templates/_look_and_feel.css.sass.erb").read.freeze
    MOBILE_LOOK_AND_FEEL_TEMPLATE = File.open("#{Rails.root}/lib/renderers/templates/_mobile_look_and_feel.css.sass.erb").read.freeze

    def initialize(css_hash)
      @css_hash = css_hash.freeze
    end

    # deprecated - legacy SERP
    def render_desktop_css
      render_css render_sass_template(ERB.new DESKTOP_LOOK_AND_FEEL_TEMPLATE, nil, '<>')
    end

    def render_mobile_css
      render_css render_sass_template(ERB.new MOBILE_LOOK_AND_FEEL_TEMPLATE, nil, '<>')
    end

    private

    def render_sass_template(template)
      template.result binding
    end

    def render_css(sass_template)
      Renderers::Sass.new(sass_template).render
    end
  end
end

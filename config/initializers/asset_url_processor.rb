# https://dev.to/kolide/how-to-migrate-a-rails-6-app-from-sass-rails-to-cssbundling-rails-4l41

class AssetUrlProcessor
  def self.call(input)
    context = input[:environment].context_class.new(input)

    data = input[:data].gsub(/(\w*)-url\(\s*["']?(?!(?:\#|data|http))([^"'\s)]+)\s*["']?\)/) do |_match|
      "url(#{context.asset_path($2, type: $1)})"
    end

    context.metadata.merge(data: data)
  end
end

Sprockets.register_postprocessor "text/css", AssetUrlProcessor

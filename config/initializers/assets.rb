(Rails.application.secrets.assets || {}).each do |k,v|
  ActionController::Base.send(:"#{k}=", v)
end

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# These are our compressors
Rails.application.config.assets.css_compressor = :yui
Rails.application.config.assets.js_compressor = :uglifier

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(font-awesome-grunticon-rails.js)
Rails.application.config.assets.precompile += %w(*.png *.gif)
Rails.application.config.assets.precompile += %w( application.css )
Rails.application.config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/javascripts/").select { |e| e =~ /^(?!application\.js).+\.js$/ }
Rails.application.config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/stylesheets/").select { |e| e =~ /^(?!application\.css).+\.css$/ }

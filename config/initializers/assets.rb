# Be sure to restart your server when you modify this file.

(Rails.application.secrets.assets || {}).each do |k,v|
  ActionController::Base.send(:"#{k}=", v)
end

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# These are our compressors
Rails.application.config.assets.css_compressor = nil
Rails.application.config.assets.js_compressor = Uglifier.new(harmony: true)

# Precompile additional assets.
Rails.application.config.assets.precompile += %w(font-awesome-grunticon-rails.js)
Rails.application.config.assets.precompile += %w(*.png *.gif)
Rails.application.config.assets.precompile += %w(application.css searches.css sites_base.css)
Rails.application.config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/javascripts/").select { |e| e =~ /^(?!application\.js).+\.js$/ }
Rails.application.config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/stylesheets/").select { |e| e =~ /^(?!application\.css).+\.css$/ }

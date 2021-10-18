# frozen_string_literal: true

Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "language_seeds" => "SEED_LANGUAGES"
  )
end

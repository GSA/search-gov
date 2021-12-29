require 'language_seeds'

class AddInferredCountryCodeToLanguages < ActiveRecord::Migration
  def up
    add_column :languages, :inferred_country_code, :string
    add_column :languages, :is_azure_supported, :boolean, default: false
    Language.all.each do |language|
      seed_language = SEED_LANGUAGES[language.code.to_sym]
      next unless seed_language
      puts "Setting inferred_country_code=#{seed_language[:inferred_country_code]}, is_azure_supported=#{seed_language[:is_azure_supported]} for #{language.code}"
      language.update({
        inferred_country_code: seed_language[:inferred_country_code],
        is_azure_supported: seed_language[:is_azure_supported]
      })
    end
  end

  def down
    remove_column :languages, :inferred_country_code
    remove_column :languages, :is_azure_supported
  end
end

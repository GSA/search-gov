require 'language_seeds'

SEED_LANGUAGES.each do |code, language|
  engines = [ ]
  engines << 'Azure' if language[:is_azure_supported]
  engines << 'Bing' if language[:is_bing_supported]
  engines << 'Google' if language[:is_google_supported]

  show =
    case engines.count
    when 0
      "unsupported"
    when 1
      "#{engines[0]}-only"
    else
      engines.join('+')
    end

  show = "#{show} (RTL)" if language[:rtl]

  puts "Creating #{show} language #{code}: #{language[:name]}" unless Rails.env.test?
  Language.create(
    code:                  code,
    rtl:                   language[:rtl],
    is_azure_supported:    language[:is_azure_supported],
    is_bing_supported:     language[:is_bing_supported],
    is_google_supported:   language[:is_google_supported],
    name:                  language[:name],
    inferred_country_code: language[:inferred_country_code],
  )
end

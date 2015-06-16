locale_with_name = {
  bs: 'Bosnian',
  kt: 'Kalaallisut',
  ky: 'Kyrgyz',
  me: 'Montenegrin',
  mn: 'Mongolian',
  ms: 'Malay',
  tg: 'Tajik',
  tk: 'Turkmen',
  en: 'English',
  es: 'Spanish',
  sq: 'Albanian',
  ar: 'Arabic',
  hy: 'Armenian',
  bn: 'Bangla',
  be: 'Belarusian',
  bg: 'Bulgarian',
  ca: 'Catalan',
  zh: 'Chinese',
  ht: 'Creole',
  hr: 'Croatian',
  cs: 'Czech',
  da: 'Danish',
  nl: 'Dutch',
  et: 'Estonian',
  fi: 'Finnish',
  fr: 'French',
  ka: 'Georgian',
  de: 'German',
  el: 'Greek',
  he: 'Hebrew',
  hi: 'Hindi',
  hu: 'Hungarian',
  id: 'Indonesian',
  it: 'Italian',
  ja: 'Japanese',
  km: 'Khmer',
  ko: 'Korean',
  lv: 'Latvian',
  lt: 'Lithuanian',
  mk: 'Macedonian',
  ps: 'Pashto',
  fa: 'Persian',
  pl: 'Polish',
  pt: 'Portugese',
  ro: 'Romanian',
  ru: 'Russian',
  sr: 'Serbian',
  sk: 'Slovak',
  sl: 'Slovene',
  so: 'Somalian',
  sw: 'Swahili',
  th: 'Thai',
  tr: 'Turkish',
  uk: 'Ukranian',
  ur: 'Urdu',
  uz: 'Uzbek',
  vi: 'Vietnamese',
  az: 'Azerbaijani',
  ha: 'Hausa',
  is: 'Icelandic',
  sv: 'Swedish',
  no: 'Norwegian'
}

both = %w(ar bg ca cs da de el en es et fi fr he hr hu id it ja ko lt lv nl pl pt ro ru sk sl sr tr zh)
bing_only = %w(be bn fa hi ht hy ka km mk ps so sq sw th uk ur uz vi)
google_only = %w(sv no)
neither = %w(az bs ha is kt ky me mn ms tg tk)
both.each do |code|
  puts "Creating Bing+Google #{code}: #{locale_with_name[code.to_sym]}"
  Language.create!(code: code, is_google_supported: true, is_bing_supported: true, name: locale_with_name[code.to_sym])
end
bing_only.each do |code|
  puts "Creating Bing-only #{code}: #{locale_with_name[code.to_sym]}"
  Language.create!(code: code, is_google_supported: false, is_bing_supported: true, name: locale_with_name[code.to_sym])
end
google_only.each do |code|
  puts "Creating Google-only #{code}: #{locale_with_name[code.to_sym]}"
  Language.create!(code: code, is_google_supported: true, is_bing_supported: false, name: locale_with_name[code.to_sym])
end
neither.each do |code|
  puts "Creating Google/Bing unsupported language #{code}: #{locale_with_name[code.to_sym]}"
  Language.create!(code: code, is_google_supported: false, is_bing_supported: false, name: locale_with_name[code.to_sym])
end
[:ar, :he, :fa, :ur].each { |rtl_locale| Language.find_by_code(rtl_locale).toggle!(:rtl) }

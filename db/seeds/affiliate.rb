# frozen_string_literal: true

Affiliate.find_or_create_by!(name: 'test_affiliate') do |affiliate|
  affiliate.display_name = 'Test Affiliate'
  affiliate.locale = 'en'
  affiliate.default_search_label = 'Search'
  affiliate.rss_govbox_label = 'News'
end

Affiliate.find_or_create_by!(name: 'spanish_affiliate') do |affiliate|
  affiliate.display_name = 'Test Spanish Affiliate'
  affiliate.locale = 'es'
  affiliate.default_search_label = 'Buscar'
  affiliate.rss_govbox_label = 'Noticias'
end

locales = %w[en es fr de ja ko zh vi ru pt it]

(3..50).each do |i|
  locale = locales[(i - 3) % locales.length]
  name = "generated_affiliate_#{i}"
  display_name = "Generated Affiliate #{i} (#{locale.upcase})"

  Affiliate.find_or_create_by!(name: name) do |affiliate|
    affiliate.display_name = display_name
    affiliate.locale = locale
    affiliate.default_search_label = locale == 'es' ? 'Buscar' : 'Search'
    affiliate.rss_govbox_label = locale == 'es' ? 'Noticias' : 'News'
  end
end

puts "Seeded #{Affiliate.count} affiliates."
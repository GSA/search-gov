Given /^the following active Spotlights exist:$/ do |table|
  table.hashes.each do |hash|
    valid_options = {:title=>hash["title"], :html=>hash["html"]}
    spotty = Spotlight.create(valid_options)
    hash["keywords"].split(',').each { |keyword| SpotlightKeyword.create(:name=> keyword.strip, :spotlight => spotty) }
    Spotlight.reindex # shouldn't be needed but cucumber scenario fails otherwise
  end
end
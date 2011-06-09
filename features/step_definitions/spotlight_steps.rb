Given /^the following active Spotlights exist:$/ do |table|
  table.hashes.each do |hash|
    valid_options = {:title=>hash["title"], :html=>hash["html"]}
    spotlight_keywords = hash["keywords"].split(',').collect { |keyword| SpotlightKeyword.new(:name=> keyword.strip) }
    spotty = Spotlight.new(valid_options)
    spotty.spotlight_keywords = spotlight_keywords
    spotty.save!
    Sunspot.commit
  end
end
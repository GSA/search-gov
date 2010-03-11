Given /^the following SAYT Suggestions exist:$/ do |table|
  table.hashes.each { |hash| SaytSuggestion.create( :phrase => hash["phrase"] ) }
end

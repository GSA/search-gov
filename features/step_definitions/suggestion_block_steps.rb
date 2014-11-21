Given /^the following Suggestion Blocks exist:$/ do |table|
  table.hashes.each do |attributes|
    SuggestionBlock.create! attributes
  end
end

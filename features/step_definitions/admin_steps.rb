Given /^the following Top Searches exist:$/ do |table|
  TopSearch.destroy_all
  table.hashes.each do |hash|
    TopSearch.create(:position => hash["position"], :query => hash["query"], :url => hash["url"].blank? ? nil : hash["url"])
  end
end

Given /^the following Top Searches exist:$/ do |table|
  TopSearch.destroy_all
  table.hashes.each do |hash|
    TopSearch.create(:position => hash["position"], :query => hash["query"], :url => hash["url"].blank? ? nil : hash["url"], :affiliate_id => hash[:affiliate_name].blank? ? nil : Affiliate.find_by_name(hash[:affiliate_name]).id)
  end
end
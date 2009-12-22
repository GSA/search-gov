Given /^the following Boosted Sites exist for the affiliate "([^\"]*)"$/ do |aff_name, table|
  affiliate = Affiliate.find_by_name aff_name
  sites = table.hashes.collect do |hash|
    BoostedSite.new(:url => hash["url"], :description => hash["description"], :title => hash["title"])
  end
  affiliate.boosted_sites << sites
end
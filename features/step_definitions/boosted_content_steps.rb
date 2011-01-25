Given /^the following Boosted Content entries exist for the affiliate "([^\"]*)"$/ do |aff_name, table|
  affiliate = Affiliate.find_by_name aff_name
  sites = table.hashes.collect do |hash|
    BoostedContent.new(:url => hash["url"], :description => hash["description"], :title => hash["title"])
  end
  affiliate.boosted_contents << sites
  Sunspot.index(sites) # because BoostedContent has auto indexing turned off for saves/creates
end

Given /^the following Boosted Content entries exist:$/ do |table|
  sites = table.hashes.collect do |hash|
    BoostedContent.create(:url => hash["url"], :description => hash["description"], :title => hash["title"], :locale => hash["locale"].present? ? hash["locale"] : I18n.default_locale.to_s)
  end
  Sunspot.index(sites) # because BoostedContent has auto indexing turned off for saves/creates
end

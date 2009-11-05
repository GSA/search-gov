Given /^the following Affiliates exist:$/ do |table|
  table.hashes.each do |hash|
    Affiliate.create(:name => hash["name"], :domains => hash["domains"], :header => hash["header"], :footer => hash["footer"])
  end
end
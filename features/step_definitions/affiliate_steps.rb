Given /^the following Affiliates exist:$/ do |table|
  table.hashes.each do |hash|
    Affiliate.create(:name => hash["name"], :contact_email => hash["contact_email"], :contact_name => hash["contact_name"])
  end
end
When /^the user agent is the MSNbot$/ do
  headers["User-Agent"] = SuperfreshUrl::MSNBOT_USER_AGENT
end
 
When /^I call the superfresh feed$/ do
  get '/superfresh', '', headers
end

Given /^the following SuperfreshUrls exist:$/ do |table|
  table.hashes.each do |hash|
    SuperfreshUrl.create(:url => hash["url"], :affiliate => Affiliate.find_by_name(hash["affiliate"]))
  end
end


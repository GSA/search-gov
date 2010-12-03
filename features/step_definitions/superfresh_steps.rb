When /^the user agent is the MSNbot$/ do
  headers["User-Agent"] = SuperfreshUrl::MSNBOT_USER_AGENT
end
 
When /^I call the superfresh feed$/ do
  get '/superfresh', '', headers
end

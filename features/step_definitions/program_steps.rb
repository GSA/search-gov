Then /^the "([^\"]*)" link should use full url$/ do |link_id|
  response.body.should have_tag("a[id=#{link_id}][href^=http]")
end


Then /^I should see hosted sitemap instructions for "([^\"]*)"$/ do |domain|
  step %{I should see "In the robots.txt file for #{domain} add this line"}
  indexed_domain = IndexedDomain.find_by_domain domain
  step %{I should see "Sitemap: http://www.example.com/usasearch_hosted_sitemap/#{indexed_domain.id}.xml"}
end
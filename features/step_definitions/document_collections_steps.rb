Given /^affiliate "([^"]*)" has a result source of "([^"]*)"$/ do |affiliate_name, results_source|
  Affiliate.find_by_name(affiliate_name).update_attribute(:results_source, results_source)
end
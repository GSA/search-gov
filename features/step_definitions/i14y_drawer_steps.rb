Given /^we don't want observers to run during these cucumber scenarios$/ do
  ActiveRecord::Observer.disable_observers
end

Given /^we want observers to run during the rest of these cucumber scenarios$/ do
  ActiveRecord::Observer.enable_observers
end

Given /^the following i14y drawers exist for (.+):$/ do |affiliate_name, table|
  table.hashes.collect do |hash|
    site = Affiliate.find_by_name affiliate_name
    site.i14y_drawers.create! hash
  end
end

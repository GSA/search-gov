Given /^the following i14y drawers exist:$/ do |table|
  ActiveRecord::Observer.disable_observers
  table.hashes.collect do |hash|
    site = Affiliate.find_by_name hash[:handle]
    site.i14y_drawers.create! hash
  end
  ActiveRecord::Observer.enable_observers
end

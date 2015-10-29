Given /^user (.+) has created the following (.+) watchers for (.+):$/ do |user_email, type, affiliate_name, table|
  site = Affiliate.find_by_name affiliate_name
  types = { "No Results" => NoResultsWatcher, "Low Query CTR" => LowQueryCtrWatcher }
  user = User.find_by_email user_email
  table.hashes.collect do |hash|
    types[type].create! hash.merge(user_id: user.id, affiliate_id: site.id)
  end
end

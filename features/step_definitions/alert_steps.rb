Given /^the following Alert exists:$/ do |table|
  table.hashes.collect do |hash|
    affiliate = Affiliate.find_by_name hash[:affiliate]
    alert = Alert.new(text: hash[:text], status: hash[:status], title: hash[:title])
    affiliate.alert = alert
    alert.save
  end
end
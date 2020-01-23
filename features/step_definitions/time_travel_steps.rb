When /^the (?:date|time) (?:is|becomes) "?(\d{4}-\d{2}-\d{2}(?: \d{1,2}:\d{2})?)"?$/ do |time|
  travel_to(Time.parse(time))
end

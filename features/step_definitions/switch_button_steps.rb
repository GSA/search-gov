Then /^the "(.+)" should be switched (on|off)$/ do |label, status|
  selector = "##{label.downcase.gsub(' ', '_')}_switch .switch-#{status}"
  page.should have_selector selector
end

When /^I switch (on|off) "(.+)"$/ do |status, label|
  cell_id = "##{label.downcase.gsub(' ', '_')}_switch"
  within cell_id do
    find('span', text: status.upcase).trigger('click')
  end
  selector = "#{cell_id} .switch-#{status}"
  find selector
end

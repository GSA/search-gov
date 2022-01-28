Then /^the "(.+)" should be switched (on|off)$/ do |label, status|
  selector = "##{label.downcase.gsub(' ', '_')}_switch .switch-#{status}"
  page.should have_selector selector
end

When /^I switch (on|off) "(.+)"$/ do |status, label|
  # To switch on, you click the visible text "off", and vice versa.
  opp_status = (status == 'on' ? 'OFF' : 'ON')
  cell_id = "##{label.downcase.gsub(' ', '_')}_switch"
  within cell_id do
    find('span', text: opp_status).click
  end
  selector = "#{cell_id} .switch-#{status}"
  find selector
end

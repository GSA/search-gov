Then /I should see the (basic|extended) header/ do |header|
  if header == 'basic'
    page.should have_selector('.usa-header--basic')
  elsif header == 'extended'
    page.should have_selector('.usa-header--extended')
  end
end

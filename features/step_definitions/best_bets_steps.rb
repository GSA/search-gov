When /^(?:|I )add the following best bets keywords:$/ do |table|
  keyword_fields_count = page.all(:css, '.keywords input').count
  table.hashes.each_with_index do |hash, index|
    click_link 'Add Another Keyword'
    keyword_label = "Keyword #{keyword_fields_count + index + 1}"
    find('label', text: keyword_label, visible: false)
    fill_in(keyword_label, with: hash[:keyword])
  end
end

Then /^(?:|I )should see the following best bets keywords:$/ do |table|
  table.hashes.each do |hash|
    page.should have_selector '.keywords li', text: hash[:keyword]
  end
end

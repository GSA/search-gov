When /^(?:|I )add the following RSS Feed URLs:$/ do |table|
  url_fields_count = page.all(:css, '.urls input[type="text"]').count
  table.hashes.each_with_index do |hash, index|
    click_link 'Add Another URL'
    url_label = "URL #{url_fields_count + index + 1}"
    find 'label', text: "#{url_label}"
    fill_in url_label, with: hash[:url]
  end
end

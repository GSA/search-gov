When(/^I close the preview layer$/) do
  find('#preview').click_button('×')
  page.has_no_selector? '#preview', visible: true
end

Then(/^the preview layer should be visible$/) do
  page.has_selector? '#preview', visible: true
end

Then(/^the preview iframe should contain "(.*?)"$/) do |text|
  page.within_frame('preview-frame') do
    page.should have_content text
  end
end

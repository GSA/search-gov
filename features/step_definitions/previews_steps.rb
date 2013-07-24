Then(/^the preview iframe should contain a link to "(.*?)"$/) do |href|
  page.within_frame('preview-frame') do
    page.should have_selector("a[href='#{href}']")
  end
end

Then /^show me the page$/ do
  screenshot_and_open_image
end

Then /^show me the console$/ do
  binding.pry
end

# e.g., And I write the page body to /tmp/test-results/look_for_this_file_in_the_artifacts_tab_in_circleci.html
When /^I write the page body to (.*)$/ do |path|
  File.open(path, 'w') { |f| f.puts(page.body) }
end
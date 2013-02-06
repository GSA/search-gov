Given /^the following Help Links exist:$/ do |table|
  table.hashes.each do |hash|
    HelpLink.create!(request_path: hash[:request_path], help_page_url: hash[:help_page_url])
  end
end

Given /^the following Help Links exist:$/ do |table|
  table.hashes.each do |hash|
    HelpLink.create(:action_name => hash[:action_name], :help_page_url => hash[:help_page_url])
  end
end

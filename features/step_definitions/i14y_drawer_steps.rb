 # NOTE: When recording new or re-recording VCR cassettes for i14y api calls,
 # your local i14y server will need to be running in test mode.
 # See https://github.com/GSA/usasearch/blob/master/README_I14Y.markdown

Given /^we don't want observers to run during these cucumber scenarios$/ do
  ApplicationRecord.observers.disable :all
end

Given /^we want observers to run during the rest of these cucumber scenarios$/ do
  ApplicationRecord.observers.enable :all
end

Then /^I should see the secret token for the "([^"]*)" drawer$/ do |handle|
  page.should have_content I14yDrawer.find_by_handle(handle).token
end

Given /^the following documents exist for the "([^"]*)" drawer:$/ do |handle, table|
  table.hashes.each do |document|
    I14yDocument.create(
      document.merge(handle: handle, document_id: Time.now.to_f)
    )
  end
end

Given(/^the "([^"]*)" drawer is shared with the "([^"]*)" affiliate$/) do |drawer, affiliate|
  drawer = I14yDrawer.find_by_handle(drawer)
  drawer.affiliates << Affiliate.find_by_name(affiliate)
  drawer.save!
end

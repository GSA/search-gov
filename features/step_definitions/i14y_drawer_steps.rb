 # NOTE: When recording new or re-recording VCR cassettes for i14y api calls,
 # your local i14y server will need to be running in test mode.
 # See https://github.com/GSA/usasearch/blob/master/README_I14Y.markdown

Given /^we don't want observers to run during these cucumber scenarios$/ do
  ActiveRecord::Observer.disable_observers
end

Given /^we want observers to run during the rest of these cucumber scenarios$/ do
  ActiveRecord::Observer.enable_observers
end

Then /^I should see the secret token for the "([^"]*)" drawer$/ do |handle|
  page.should have_content I14yDrawer.find_by_handle(handle).token
end

Given /^the following documents exist for the "([^"]*)" drawer:$/ do |drawer, table|
  drawer = I14yDrawer.find_by_handle(drawer)
  conn = Faraday.new(url: "#{I14yCollections.host}/api/v1/documents")
  conn.basic_auth(drawer.handle, drawer.token)
  table.hashes.each do |document|
    conn.post do |req|
      req.body = document.merge(token: drawer.token, handle: drawer.handle, document_id: Time.now.to_f)
    end
  end
end


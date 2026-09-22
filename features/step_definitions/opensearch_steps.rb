# frozen_string_literal: true

Given /^the following OpenSearch documents exist:$/ do |table|
  OpenSearchCucumberDocuments.index_documents(table.hashes)
end

Given /^there are results for the "([^"]*)" drawer$/ do |_drawer|
  OpenSearchCucumberDocuments.ensure_seeded!
end

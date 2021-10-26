Given /^the following IndexedDocuments exist:$/ do |table|
  table.hashes.each do |hash|
    attributes = hash.except('published_ago')
    attributes['affiliate'] &&= Affiliate.find_by(name: attributes['affiliate'])
    attributes['doctype'] ||= 'html'
    if hash['published_ago'].present?
      attributes['published_at'] = eval(hash['published_ago'].gsub(/ /, '.'))
    end

    IndexedDocument.create! attributes
  end
  ElasticIndexedDocument.commit
end

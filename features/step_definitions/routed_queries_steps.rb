Given /^affiliate "([^"]*)" has the following routed quer(y|ies):$/ do |affiliate_name, _, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    routed_query = affiliate.routed_queries.new(description: hash[:description], url: hash[:url])
    keywords = hash[:keywords].split(',')
    keywords.each do |kw|
      routed_query.routed_query_keywords.build(keyword: kw)
    end
    routed_query.save!
  end
end

When /^(?:|I )add the following Routed Query Keywords:$/ do |table|
  keywords_count = page.all(:css, '.routed-query-keywords input[type="text"]').count
  table.hashes.each_with_index do |hash, index|
    click_link 'Add Another Keyword'
    keyword_label = "Keyword or phrase #{keywords_count + index + 1}"
    find('label', text: keyword_label, visible: false)
    fill_in keyword_label, with: hash[:keyword]
  end
end

When /^(?:|I )replace the Routed Query Keywords with:$/ do |table|
  table.hashes.each_with_index do |hash, index|
    keyword_label = "Keyword or phrase #{index + 1}"
    find('label', text: keyword_label, visible: false)
    fill_in keyword_label, with: hash[:keyword]
  end
end

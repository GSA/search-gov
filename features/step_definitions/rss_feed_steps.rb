When /^(?:|I )add the following RSS Feed URLs:$/ do |table|
  url_fields_count = page.all(:css, '.urls input[type="text"]').count
  table.hashes.each_with_index do |hash, index|
    click_link 'Add Another URL'
    url_label = "URL #{url_fields_count + index + 1}"
    find('label', text: url_label, visible: false)
    fill_in url_label, with: hash[:url]
  end
end

# RSS feed responses can't be recorded by VCR due to
# https://cm-jira.usa.gov/browse/SRCH-645. Until that is resolved, we
# can stub generic RSS responses using this step definition.
Given /^([^"]*) has valid RSS feeds/ do |domain|
  feed_content = Rails.root.join('spec/fixtures/rss/wh_blog.xml').read

  stub_request(:get, %r{https://#{domain}/rss/}).
    to_return(status: 200, body: feed_content)
end

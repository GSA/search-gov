CrawlConfig.create do |c|
  c.name = 'searchgov'
  c.allowed_domains = ['www.search.gov']
  c.starting_urls = ['https://www.search.gov/']
  c.schedule = '0 0 * * *'
  c.depth_limit = 1
end

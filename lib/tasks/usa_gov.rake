namespace :usasearch do
  desc "Crawls usa.gov sitemap and creates local mobile version of the site, erasing any prior structure"
  task :crawl_usa_gov => :environment do
    SitePage.crawl_usa_gov
  end
end
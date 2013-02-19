namespace :usasearch do
  desc "Crawls usa.gov sitemap and creates local mobile version of the site, erasing any prior structure"
  task :crawl_usa_gov => :environment do
    SitePage.crawl_usa_gov
  end

  desc "Crawls answers.usa.gov and creates local mobile version of the site, erasing any prior answers"
  task :crawl_answers_usa_gov => :environment do
    SitePage.crawl_answers_usa_gov
  end

end
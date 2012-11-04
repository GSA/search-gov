namespace :usasearch do
  desc "Crawls usa.gov sitemap and creates local mobile version of the site, erasing any prior structure"
  task :crawl_usa_gov => :environment do
    SitePage.crawl_usa_gov
  end

  desc "Crawls answers.usa.gov and creates local mobile version of the site, erasing any prior answers"
  task :crawl_answers_usa_gov => :environment do
    SitePage.crawl_answers_usa_gov
  end

  desc "Scan Bing results on gov/mil sites for objectionable content and notify recipient when found"
  task :detect_objectionable_content, [:email] => :environment do |t, args|
    args.with_defaults(:email => "amy.farrajfeijoo@gsa.gov")
    usagov_affiliate = Affiliate.find_by_name Affiliate::USAGOV_AFFILIATE_NAME
    results = SaytFilter.find_all_by_always_filtered(true).find_all do |sf|
      WebSearch.results_present_for?(sf.phrase, usagov_affiliate, true, "off")
    end
    Emailer.objectionable_content_alert(args.email, results.collect(&:phrase)).deliver if results.present?
  end
end
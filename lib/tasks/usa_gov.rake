namespace :usasearch do
  desc "Crawls usa.gov sitemap and creates local mobile version of the site, erasing any prior structure"
  task :crawl_usa_gov => :environment do
    SitePage.crawl_usa_gov
  end

  desc "Scan Bing results on gov/mil sites for objectionable content and notify recipient when found"
  task :detect_objectionable_content, :email, :needs => :environment do |t, args|
    args.with_defaults(:email => "amy.farrajfeijoo@gsa.gov")
    results = SaytFilter.find_all_by_always_filtered(true).find_all do |sf|
      Search.results_present_for?(sf.phrase, nil, true, "off")
    end
    Emailer.deliver_objectionable_content_alert(args.email, results.collect(&:phrase)) if results.present?
  end
end
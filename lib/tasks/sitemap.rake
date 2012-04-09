namespace :usasearch do
  namespace :sitemap do
    desc "Fetches and indexes URLs in sitemaps."
    task :refresh => :environment do
      Sitemap.refresh
    end
  end
end
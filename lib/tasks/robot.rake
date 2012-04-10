namespace :usasearch do
  namespace :robot do
    desc "Build exclusion lists around robots.txt files for each domain"
    task :populate => :environment do
      Robot.populate_from_indexed_domains
    end
  end
end
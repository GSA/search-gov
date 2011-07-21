namespace :usasearch do
  namespace :boosted_content do
    desc "Prune old auto-generated boosted sites"
    task :prune => :environment do
      BoostedContent.delete_all(["created_at < ? and auto_generated = true", 7.days.ago.beginning_of_day.to_s(:db)])
    end
  end
end
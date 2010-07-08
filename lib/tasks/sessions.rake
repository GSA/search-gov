namespace :usasearch do
  namespace :sessions do
    desc "Prune old session data"
    task :prune => :environment do
      Session.delete_all(["created_at < ?", 7.days.ago.beginning_of_day.to_s(:db)])
    end
  end
end
namespace :db do
  task :setup => 'search_elastic:create_index'
end

namespace :search_elastic do
  desc 'Create an index for search_elastic engine'
  task create_index: :environment do
    Es.create_index()
  end
end

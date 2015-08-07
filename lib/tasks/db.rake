namespace :usasearch do
  namespace :db do
    namespace :structure do
      desc 'strip AUTO_INCREMENT from db/structure.sql'
      task :strip_auto_increment => :environment do
        path = Rails.root.join('db', 'structure.sql')
        File.write path, File.read(path).gsub(/ AUTO\_INCREMENT=\d+/, '')
      end
    end
  end
end

Rake::Task['db:structure:dump'].enhance do
  Rake::Task['usasearch:db:structure:strip_auto_increment'].execute
end

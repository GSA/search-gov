namespace :usasearch do
  namespace :db do
    desc 'migrate and strip AUTO_INCREMENT from db/structure.sql'
    task :migrate => :environment do
      Rake::Task['db:migrate'].invoke
      Rake::Task['usasearch:db:structure:strip_auto_increment'].invoke
    end

    desc 'strip AUTO_INCREMENT from db/structure.sql'
    namespace :structure do
      desc 'dump structure and strip AUTO_INCREMENT from db/structure.sql'
      task :dump => :environment do
        Rake::Task['db:structure:dump'].invoke
        Rake::Task['usasearch:db:structure:strip_auto_increment'].invoke
      end

      desc 'strip AUTO_INCREMENT from db/structure.sql'
      task :strip_auto_increment => :environment do
        path = Rails.root.join('db', 'structure.sql')
        File.write path, File.read(path).gsub(/ AUTO\_INCREMENT=\d+/, '')
      end
    end
  end
end

namespace :usasearch do
  namespace :db do
    %w(migrate rollback).each do |task_name|
      desc "Invoke db:#{task_name} and strip AUTO_INCREMENT from db/structure.sql"
      task task_name.to_sym => :environment do |t|
        execute_db_task_and_strip_auto_increment(t.name)
      end
    end

    namespace :migrate do
      %w(redo up down).each do |task_name|
        desc "Invoke db:migrate:#{task_name} and strip AUTO_INCREMENT from db/structure.sql"
        task task_name.to_sym => :environment do |t|
          execute_db_task_and_strip_auto_increment(t.name)
        end
      end
    end

    namespace :structure do
      desc 'Invoke db:migrate:structure:dump and strip AUTO_INCREMENT from db/structure.sql'
      task :dump => :environment do |t|
        execute_db_task_and_strip_auto_increment(t.name)
      end

      desc 'strip AUTO_INCREMENT from db/structure.sql'
      task :strip_auto_increment => :environment do
        path = Rails.root.join('db', 'structure.sql')
        File.write path, File.read(path).gsub(/ AUTO\_INCREMENT=\d+/, '')
      end
    end
  end

  def execute_db_task_and_strip_auto_increment(task_name)
    Rake::Task[task_name.gsub(/\Ausasearch:/, '')].invoke
    Rake::Task['usasearch:db:structure:strip_auto_increment'].invoke
  end
end

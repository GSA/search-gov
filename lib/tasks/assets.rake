namespace :assets do
  desc 'Precompile assets if the current environment requires it'
  task :maybe_precompile => :environment do
    unless UsasearchRails3::Application.config.serve_static_assets
      Rake::Task['assets:precompile'].invoke
    end
  end
end

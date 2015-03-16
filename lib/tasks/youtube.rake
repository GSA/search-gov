namespace :usasearch do
  namespace :youtube do
    desc 'Refresh YouTube profiles'
    task :refresh => :environment do
      YoutubeData.refresh
    end
  end
end


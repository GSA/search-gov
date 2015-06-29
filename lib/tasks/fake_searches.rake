namespace :fake do
  namespace :searches do
    HUMAN_PROBABILITY_PCT = 90
    RESULTS_PER_SEARCH = 10
    CLICKS_PER_SEARCH = 2

    desc 'generate fake searches and clicks for the current month'
    task :month, [:site_handle, :variation_count, :search_session_count] => [:environment] do |t, args|
      puts "producing #{args[:site_handle]} searches and clicks for current month"
      fake = DataGenerator::Fake.new(Date.today.beginning_of_month, Date.today.end_of_month, HUMAN_PROBABILITY_PCT, search_modules)
      generate_sessions(fake, args[:site_handle], args[:variation_count].to_i, args[:search_session_count].to_i)
    end

    desc 'generate fake searches and clicks for the current day'
    task :day, [:site_handle, :variation_count, :search_session_count] => [:environment] do |t, args|
      puts "producing #{args[:site_handle]} searches and clicks for today"
      fake = DataGenerator::Fake.new(Date.today, Date.today, HUMAN_PROBABILITY_PCT, search_modules)
      generate_sessions(fake, args[:site_handle], args[:variation_count].to_i, args[:search_session_count].to_i)
    end
  end
end

def search_modules
  RESULTS_PER_SEARCH == 0 ? [] : SearchModule.pluck(:tag)
end

def generate_sessions(fake, site_handle, variation_count, search_session_count)
  pool = DataGenerator::SearchPool.new(variation_count, RESULTS_PER_SEARCH, CLICKS_PER_SEARCH, fake)

  search_session_count.times do
    search = pool.search_session
    index = DataGenerator::IndexAdapter.new(site_handle, search)
    index.index_search_and_clicks
  end
end

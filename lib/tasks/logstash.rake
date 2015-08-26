namespace :usasearch do
  namespace :logstash do
    desc 'Delete duplicate search requests across some date range. Format YYYY-MM-DD.'
    task :dedupe, [:start_date, :end_date] => :environment do |t, args|
      start_date = Date.parse(args.start_date)
      end_date = Date.parse(args.end_date)
      range = start_date..end_date
      range.each { |day| Resque.enqueue_with_priority(:low, LogstashDeduper, day.strftime("%Y.%m.%d")) }
    end

  end
end

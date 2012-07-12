namespace :usasearch do
  namespace :daily_left_nav_stat do
    desc "Loads ctrl-A-delimited file of affiliate name, path, dc, channel, tbs, count as new DailyLeftNavStats for a given day"
    task :bulk_load, [:data_file, :day] => [:environment] do |t, args|
      if args.data_file.blank? or args.day.blank?
        Rails.logger.error("usage: rake usasearch:daily_left_nav_stat:bulk_load[/path/to/file,yyyymmdd]")
      else
        DailyLeftNavStat.bulk_load(args.data_file, args.day)
      end
    end
  end
end
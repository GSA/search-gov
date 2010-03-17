namespace :usasearch do
  namespace :recalls do

    desc "Load recalls from spreadsheet/CSV from CPSC"
    task :load, :recalls_csv_filename, :needs => :environment do |t, args|
      if args.recalls_csv_filename.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load[/path/to/recalls/csv]")
      else
        Recall.load_from_csv_file(args.recalls_csv_filename)
      end
    end
  end
end
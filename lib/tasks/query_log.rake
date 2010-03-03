namespace :usasearch do
  namespace :query_log do

    desc "Process a directory of Vivisimo query log files (NCSA format 1)"
    task :process, :log_dir_name, :destination_log_dir_root, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:query_log:process log_dir_name destination_log_dir_root") and return if (args.log_dir_name.nil? || args.destination_log_dir_root.nil?)
      Dir.glob("#{args.log_dir_name}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.log") do |file|
        LogFile.process(file)
        destination_log_dir_name = File.basename(file)[0, 7]
        destination_dir = [args.destination_log_dir_root, destination_log_dir_name].join("/")
        FileUtils.mkdir(destination_dir) unless File.directory?(destination_dir)
        FileUtils.cp(file, destination_dir)
      end
    end

    desc "Import a directory of search query log files (NCSA combined)"
    task :import, :log_dir_name, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:query_log:import log_dir_name") and return if args.log_dir_name.nil?
      Dir.glob("#{args.log_dir_name}/[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]_web*.log") { |file| LogFile.process(file) }
    end
  end
end
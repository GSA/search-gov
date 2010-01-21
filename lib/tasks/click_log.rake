namespace :usasearch do
  namespace :click_log do

    desc "Process a directory of Apache log files for clicks (NCSA format 1)"
    task :process, :log_dir_name, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:click_log:process[ log_dir_name ]") and return if (args.log_dir_name.nil?)
      Dir.glob("#{args.log_dir_name}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.log") do |file|
        LogFile.process_clicks(file)
      end
    end  
  end
end
namespace :usasearch do
  namespace :bulk_import do
      
    desc "Bulk Import Affiliates via CSV"
    task :affiliate_csv, :csv_file, :needs => :environment do |t, args|
      unless args.csv_file
        Rails.logger.error("usage: rake usasearch:bulk_import:affiliate_csv[/path/to/affiliate/csv]")
      else
        FasterCSV.parse(File.open(args.csv_file).read, :skip_blanks => true, :headers => true) do |row|
          begin
            affiliate_attributes = {
                :display_name => row[0],
                :name => row[1],
                :domains => row[2].gsub(/,/, "\n"),
                :header => row[3],
                :footer => row[4],
                :website => row[5]
            }
            affiliate = Affiliate.new(affiliate_attributes)
            users = row[6].split(",").collect{|email| User.find_by_email(email)}
            affiliate.users << users
            affiliate.save! 
          rescue 
            Rails.logger.error("Unable to create affiliate with name: #{affiliate_attributes[:name]}.")
            Rails.logger.error("Additional information: #{affiliate.errors.full_messages.to_sentence}") if affiliate and affiliate.errors.empty? == false
          end
        end
      end
    end
  end
end
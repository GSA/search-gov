namespace :usasearch do
  namespace :bulk_import do

    desc "Bulk add user to affiliates via CSV"
    task :affiliate_csv, [:csv_file, :email_address] => [:environment] do |t, args|

      user = User.find_by_email(args.email_address)
      puts "Added user #{user.email} to the following sites:"

      CSV.foreach(args.csv_file) do |row|
        affiliate_name = row[0]
        site = Affiliate.find_by_name(affiliate_name)

        if site
          if site.users.exists?(id: user.id)
            puts "#{affiliate_name}: skipped - user already a member"
          else
            user.add_to_affiliate(site, 'A script')
            puts "#{affiliate_name}"
          end
        else
          puts "#{affiliate_name}: FAILURE - site not found"
        end
      end
    end
  end
end

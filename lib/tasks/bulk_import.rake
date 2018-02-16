namespace :usasearch do
  namespace :bulk_import do

    desc "Bulk Import from Google Search Appliance XML"
    task :google_xml, [:xml_file, :default_email] => [:environment] do |t, args|
      default_user = User.find_by_email(args.default_email)
      xml_doc = Nokogiri::XML(File.read(args.xml_file))

      xml_doc.xpath("//collection").each do |collection|
        site_handle = collection.attributes["Name"].value
        affiliate = Affiliate.find_or_initialize_by(name: site_handle.downcase)
        affiliate.display_name = site_handle if affiliate.display_name.blank?
        affiliate.users << default_user unless affiliate.users.exists?(id: default_user.id)
        collection.xpath("good_urls").inner_text.split.each do |site_domain|
          affiliate.site_domains << SiteDomain.new(:domain => site_domain)
        end
        affiliate.save
      end
    end

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

namespace :usasearch do
  namespace :bulk_import do
  
    desc "Bulk Import from Google Search Appliance XML"
    task :google_xml, [:xml_file, :default_email] => [:environment] do |t, args|
      default_user = User.find_by_email(args.default_email)
      xml_doc = Nokogiri::XML(File.read(args.xml_file))
      xml_doc.xpath("//collection").each do |collection|
        site_handle = collection.attributes["Name"].value
        affiliate = Affiliate.find_or_initialize_by_name(site_handle.downcase)
        affiliate.display_name = site_handle if affiliate.display_name.blank?
        affiliate.users << default_user unless affiliate.users.include?(default_user)
        collection.xpath("good_urls").inner_text.split.each do |site_domain|
          affiliate.site_domains << SiteDomain.new(:domain => site_domain)
        end
        affiliate.save
      end
    end
  end
end
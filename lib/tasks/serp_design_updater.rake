namespace :searchgov do
  desc 'Migrate design settings for the redesigned SERP via CSV'
  # Usage: rake searchgov:migrate_designs[site_attributes.csv]

  task :migrate_designs, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file

    CSV.foreach(csv_file, headers: true) do |row|
      affiliate = Affiliate.find(row['ID'])

      # Create all links
      for index in 0..11
        title_key = "primary_header_links #{index} - title"
        url_key = "primary_header_links #{index} - url"
        primary_header_link == PrimaryHeaderLink.create(position: index, type: 'PrimaryHeaderLink', title: row[title_key], url: row[url_key])
        affiliate.primary_header_links << primary_header_link if primary_header_link.valid?
      end

      for index in 0..2
        title_key = "secondary_header_links #{index} - title"
        url_key = "secondary_header_links #{index} - url"
        secondary_header_link == SecondaryHeaderLink.create(position: index, type: 'SeconaryHeaderLink', title: row[title_key], url: row[url_key])
        affiliate.secondary_header_links << secondary_header_link if secondary_header_link.valid?
      end

      for index in 0..12
        title_key = "footer_links #{index} - title"
        url_key = "footer_links #{index} - url"
        footer_link == FooterLink.create(position: index, type: 'FooterLink', title: row[title_key], url: row[url_key])
        affiliate.footer_links << footer_link if footer_link.valid?
      end

      for index in 0..6
        title_key = "identifier_links #{index} - title"
        url_key = "identifier_links #{index} - url"
        identifier_link == IdentifierLink.create(position: index, type: 'IdentifierLink', title: row[title_key], url: row[url_key])
        affiliate.identifier_links << identifier_link if identifier_link.valid?
      end

      affiliate.display_logo_only = row['display_logo_only']

      affiliate.agency&.name = row['site_parent_agency_name']
      affiliate.agency&.url = row['site_parent_agency_link']
    end
  end
end

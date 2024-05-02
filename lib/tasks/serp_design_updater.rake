namespace :searchgov do
  desc 'Migrate design settings for the redesigned SERP via CSV'
  # Usage: rake searchgov:migrate_designs[site_attributes.csv]

  task :migrate_designs, [:csv_file] => [:environment] do |_t, args|
    csv_file = args.csv_file
    headers = CSV.open(csv_file, 'r') { |csv| csv.first }
    puts headers
    headers_read = false
    CSV.foreach(csv_file) do |row|
      if !headers_read
        headers_read = true
        next
      end
      affiliate_id = row.first
      affiliate = Affiliate.find(affiliate_id)
      # WIP
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[6].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[6], url: row[7])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[8].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[8], url: row[9])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[10].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[10], url: row[11])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[12].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[12], url: row[13])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[14].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[14], url: row[15])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[16].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[16], url: row[17])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[18].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[18], url: row[19])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[20].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[20], url: row[21])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[22].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[22], url: row[23])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[24].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[24], url: row[25])
      affiliate.primary_header_links << PrimaryHeaderLink.create(position: headers[26].scan(/\d+/).first, type: 'PrimaryHeaderLink', title: row[26], url: row[27])

      affiliate.secondary_header_links << SecondaryHeaderLink.create(position: headers[28].scan(/\d+/).first, type: 'SecondaryHeaderLink', title: row[28], url: row[29])
      affiliate.secondary_header_links << SecondaryHeaderLink.create(position: headers[30].scan(/\d+/).first, type: 'SecondaryHeaderLink', title: row[30], url: row[31])
      affiliate.secondary_header_links << SecondaryHeaderLink.create(position: headers[32].scan(/\d+/).first, type: 'SecondaryHeaderLink', title: row[32], url: row[33])

      affiliate.display_logo_only = row[34]

      affiliate.footer_links << FooterLink.create(position: headers[35].scan(/\d+/).first, type: 'FooterLink', title: row[35], url: row[36])
      affiliate.footer_links << FooterLink.create(position: headers[37].scan(/\d+/).first, type: 'FooterLink', title: row[37], url: row[38])
      affiliate.footer_links << FooterLink.create(position: headers[39].scan(/\d+/).first, type: 'FooterLink', title: row[39], url: row[40])
      affiliate.footer_links << FooterLink.create(position: headers[41].scan(/\d+/).first, type: 'FooterLink', title: row[41], url: row[42])
      affiliate.footer_links << FooterLink.create(position: headers[43].scan(/\d+/).first, type: 'FooterLink', title: row[43], url: row[44])
      affiliate.footer_links << FooterLink.create(position: headers[45].scan(/\d+/).first, type: 'FooterLink', title: row[45], url: row[46])
      affiliate.footer_links << FooterLink.create(position: headers[47].scan(/\d+/).first, type: 'FooterLink', title: row[47], url: row[48])
      affiliate.footer_links << FooterLink.create(position: headers[49].scan(/\d+/).first, type: 'FooterLink', title: row[49], url: row[50])
      affiliate.footer_links << FooterLink.create(position: headers[51].scan(/\d+/).first, type: 'FooterLink', title: row[51], url: row[52])
      affiliate.footer_links << FooterLink.create(position: headers[53].scan(/\d+/).first, type: 'FooterLink', title: row[53], url: row[54])
      affiliate.footer_links << FooterLink.create(position: headers[55].scan(/\d+/).first, type: 'FooterLink', title: row[55], url: row[56])
      affiliate.footer_links << FooterLink.create(position: headers[57].scan(/\d+/).first, type: 'FooterLink', title: row[57], url: row[58])
      affiliate.footer_links << FooterLink.create(position: headers[59].scan(/\d+/).first, type: 'FooterLink', title: row[59], url: row[60])

      affiliate.identifier_links << IdentifierLink.create(position: headers[60].scan(/\d+/).first, type: 'FooterLink', title: row[60], url: row[61])
      affiliate.identifier_links << IdentifierLink.create(position: headers[62].scan(/\d+/).first, type: 'FooterLink', title: row[62], url: row[63])
      affiliate.identifier_links << IdentifierLink.create(position: headers[64].scan(/\d+/).first, type: 'FooterLink', title: row[64], url: row[65])
      affiliate.identifier_links << IdentifierLink.create(position: headers[66].scan(/\d+/).first, type: 'FooterLink', title: row[66], url: row[67])
      affiliate.identifier_links << IdentifierLink.create(position: headers[68].scan(/\d+/).first, type: 'FooterLink', title: row[68], url: row[69])
      affiliate.identifier_links << IdentifierLink.create(position: headers[70].scan(/\d+/).first, type: 'FooterLink', title: row[70], url: row[71])
      affiliate.identifier_links << IdentifierLink.create(position: headers[72].scan(/\d+/).first, type: 'FooterLink', title: row[72], url: row[73])
    end
  end
end

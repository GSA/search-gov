namespace :usasearch do
  namespace :recalls do

    desc "Load recalls from spreadsheet/CSV from CPSC"
    task :load_cpsc_data, :recalls_csv_filename, :needs => :environment do |t, args|
      if args.recalls_csv_filename.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load_cpsc_data[/path/to/recalls/csv]")
      else
        Recall.load_cpsc_data_from_file(args.recalls_csv_filename)
      end
    end

    desc "Load recalls from CPSC XML feed"
    task :read_cpsc_feed, :xml_url, :needs => :environment do |t, args|
      if args.xml_url.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:read_cpsc_feed[XML Feed URL]")
      else
        Recall.load_cpsc_data_from_xml_feed(args.xml_url)
      end
    end

    desc "Load recalls from NHTSA tab-delimited feed"
    task :read_nhtsa_feed, :tab_delimited_url, :needs => :environment do |t, args|
      if args.tab_delimited_url.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:read_nhtsa_feed[Tab-delimited Feed URL]")
      else
        Recall.load_nhtsa_data_from_tab_delimited_feed(args.tab_delimited_url)
      end
    end

    desc "Load NHTSA recalls from tab-delimited file"
    task :load_nhtsa_data, :data_file, :needs => :environment do |t, args|
      if args.data_file.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load_nhtsa_data[/path/to/recalls/file]")
      else
        Recall.load_nhtsa_data_from_file(args.data_file)
      end
    end

    desc "Load/update CDC food recall data from RSS feed"
    task :load_cdc_data, :rss_url, :food_type, :needs => :environment do |t, args|
      if args.rss_url.blank? || args.food_type.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load_cdc_data[RSS Feed URL, food type]")
      else
        Recall.load_cdc_data_from_rss_feed(args.rss_url, args.food_type)
      end
    end

    desc "Add sample UPC data to Recalls"
    task :load_sample_upc_data, :needs => :environment do
      upcs = {'05586' => '718103051743', '05224' => '016256658148', '05225' => '717103051750', '05587' => '021200140624', '05226' => '071641880740', '05227' => '077914050179', '05228' => '077914050179', '05229' => '718103201384', '05230' => '718103201384', '05231' => '718103201384', '05589' => '070330201286', '05232' => '070330201286', '05233' => '718103010344', '05234' => '718103010344', '05235' => '718103010344', '05236' => '718103121866', '05237' => '718103121866', '05238' => '718103121866', '05592' => '718103121866', '05593' => '718103121866'}
      upcs.each_pair do |recall_number, upc|
        recall = Recall.find_by_recall_number(recall_number)
        if recall
          recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => upc)
          recall.save!
        end
      end
    end

  end
end

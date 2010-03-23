namespace :usasearch do
  namespace :recalls do

    desc "Load recalls from spreadsheet/CSV from CPSC"
    task :load_cpsc_data, :recalls_csv_filename, :needs => :environment do |t, args|
      if args.recalls_csv_filename.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load_cpsc_data[/path/to/recalls/csv]")
      else
        Recall.load_cpsc_data_from_file(args.recalls_csv_filename)
        Recall.reindex
      end
    end
    
    desc "Load NHTSA recalls from tab-delimited file"
    task :load_nhtsa_data, :data_file, :needs => :environment do |t, args|
      if args.data_file.blank?
        RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:recalls:load_nhtsa_data[/path/to/recalls/file]")
      else
        Recall.load_nhtsa_data_from_file(args.data_file)
        Recall.reindex
      end
    end
    
    desc "Add sample UPC data to Recalls"
    task :load_sample_upc_data, :needs => :environment do |t, args|
      upcs = {'05586' => '718103051743', '05224' => '016256658148', '05225' => '717103051750', '05587' => '021200140624', '05226' => '071641880740', '05227' => '077914050179', '05228' => '077914050179', '05229' => '718103201384', '05230' => '718103201384', '05231' => '718103201384', '05589' => '070330201286', '05232' => '070330201286', '05233' => '718103010344', '05234' => '718103010344', '05235' => '718103010344', '05236' => '718103121866', '05237' => '718103121866', '05238' => '718103121866', '05592' => '718103121866', '05593' => '718103121866'}
      upcs.each_pair do |recall_number, upc|
        recall = Recall.find_by_recall_number(recall_number)
        if recall
          recall.recall_details << RecallDetail.new(:detail_type => 'UPC', :detail_value => upc)
          recall.save!
        end
      end
      Recall.reindex
    end
    
  end
end
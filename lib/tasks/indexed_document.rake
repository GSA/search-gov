namespace :usasearch do
  namespace :indexed_document do
    desc "Fetches and indexes Affiliate indexed documents. Accepts 'not_ok', 'ok', and 'unfetched'."
    task :refresh, :extent, :needs => :environment do |t, args|
      IndexedDocument.refresh(args.extent)
    end

    desc "Loads tab-delimited file of affiliate ID / URL pairs as new IndexedDocuments"
    task :bulk_load_urls, :data_file, :needs => :environment do |t, args|
      if args.data_file.blank?
        Rails.logger.error("usage: rake usasearch:indexed_document:bulk_load_urls[/path/to/aid_urls/file]")
      else
        IndexedDocument.bulk_load_urls(args.data_file)
      end
    end
  end
end
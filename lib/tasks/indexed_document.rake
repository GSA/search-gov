namespace :usasearch do
  namespace :indexed_document do
    desc "Freshens and reindexes all Affiliate indexed documents"
    task :refresh_all => :environment do
      IndexedDocument.refresh_all
    end

    desc "Indexes all unfetched Affiliate documents"
    task :index_unindexed => :environment do
      IndexedDocument.index_unindexed
    end
 end
end
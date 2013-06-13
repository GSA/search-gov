namespace :usasearch do
  namespace :indexed_document do
    desc "Fetches and indexes Affiliate indexed documents. Accepts 'not_ok', 'ok', and 'unfetched'."
    task :refresh, [:extent] => [:environment] do |t, args|
      IndexedDocument.refresh(args.extent)
    end
  end
end
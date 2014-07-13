namespace :usasearch do
  namespace :federal_register_documents do
    desc 'Import federal register documents'
    task :import, [:load_all] => :environment do |_t, args|
      args.with_defaults(load_all: false)
      load_all = args.load_all =~ /true/i ? true : false
      FederalRegisterDocumentData.import load_all: load_all
    end
  end
end

namespace :usasearch do
  namespace :federal_register_documents do
    desc 'Import federal register documents'
    task :import => :environment do
      FederalRegisterDocumentData.import
    end
  end
end

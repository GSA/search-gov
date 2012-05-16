namespace :usasearch do
  namespace :indexed_domain do
    desc "Detects and removes common template code and nav elements from IndexedDocuments for each IndexedDomain"
    task :detect_templates => :environment do
      IndexedDomain.detect_templates
    end
  end
end
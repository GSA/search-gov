# frozen_string_literal: true

namespace :usasearch do
  namespace :federal_register do
    desc 'Import federal register agencies'
    task import_agencies: :environment do
      FederalRegisterAgencyData.import
    end

    desc 'Import federal register documents'
    task :import_documents, [:load_all] => :environment do |_t, args|
      args.with_defaults(load_all: false)
      load_all = args.load_all.is_a?(String) && args.load_all.match?(/true/i)
      FederalRegisterDocumentData.import(load_all:)
    end
  end
end

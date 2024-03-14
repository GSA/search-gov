# frozen_string_literal: true

namespace :usasearch do
  namespace :medline do
    desc 'load medline vocab xml'
    task :load, [:date] => [:environment] do |_t, args|
      effective_date = args.date.blank? ? nil : Date.parse(args.date)
      medline_xml_file_path = MedTopic.download_medline_xml(effective_date)
      MedTopic.process_medline_xml(medline_xml_file_path)
    end
  end
end

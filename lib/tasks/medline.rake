namespace :usasearch do
  namespace :medline do

    desc "lint medline vocab xml from Medline"
    task :lint, :date, :needs => :environment do |t, args|
      effective_date = args.date.blank? ? nil : Date.parse(args.date)
      MedTopic.lint_medline_xml_for_date(effective_date) { |msg| puts msg }
    end

    desc "diff medline vocab xml"
    task :diff, :from_date, :to_date, :needs => :environment do |t, args|
      effective_from_date = args.from_date.blank? ? nil : Date.parse(args.from_date)
      effective_to_date = args.to_date.blank? ? nil : Date.parse(args.to_date)
      from_state = effective_from_date.nil? ? MedTopic.dump_db_vocab() : MedTopic.parse_medline_xml_vocab(MedTopic.medline_xml_for_date(effective_from_date))
      to_state = MedTopic.parse_medline_xml_vocab(effective_to_date.nil? ? MedTopic.medline_xml_for_date(nil) : MedTopic.medline_xml_for_date(effective_to_date))
      delta = MedTopic.delta_medline_vocab(from_state, to_state)
      delta.each { |action, data| puts "#{data.size} #{action}" }
    end

    desc "load medline vocab xml"
    task :load, :date, :needs => :environment do |t, args|
      effective_date = args.date.blank? ? nil : Date.parse(args.date)
      from_state = MedTopic.dump_db_vocab()
      to_state = MedTopic.parse_medline_xml_vocab(MedTopic.medline_xml_for_date(effective_date))
      delta = MedTopic.delta_medline_vocab(from_state, to_state)
      MedTopic.apply_vocab_delta(delta)
    end
  end
end

namespace :usasearch do
  namespace :medline do

    desc "lint medline vocab xml from Medline"
    task :lint, :date, :needs => :environment do |t, args|

      effective_date = if args.date.blank?
		nil
	  else
	    Date.parse( args.date ) 
      end

	  MedTopic.lint_medline_xml_for_date( effective_date ) { |msg| puts msg }

    end

    desc "diff medline vocab xml"
    task :diff, :from_date, :to_date, :needs => :environment do |t, args|

      effective_from_date = if args.from_date.blank?
		nil
	  else
	    Date.parse( args.from_date ) 
      end

      effective_to_date = if args.to_date.blank?
		nil
	  else
	    Date.parse( args.to_date ) 
      end

	  from_state = if effective_from_date.nil?
		MedTopic.dump_db_vocab()
	  else
		MedTopic.parse_medline_xml_vocab(MedTopic.medline_xml_for_date( effective_from_date ))
	  end

	  to_state = MedTopic.parse_medline_xml_vocab( 
			if effective_to_date.nil?
				MedTopic.medline_xml_for_date( nil )
	  		else
				MedTopic.medline_xml_for_date( effective_to_date )
	  		end
      )

      delta = MedTopic.delta_medline_vocab( from_state, to_state )
	  delta.each { |action, data| puts "#{data.size} #{action}" }

    end

    desc "load medline vocab xml"
    task :load, :date, :needs => :environment do |t, args|

      effective_date = if args.date.blank?
		nil
	  else
	    Date.parse( args.date ) 
      end

	  from_state = MedTopic.dump_db_vocab()
	  to_state = MedTopic.parse_medline_xml_vocab( MedTopic.medline_xml_for_date( effective_date ) )
      delta = MedTopic.delta_medline_vocab( from_state, to_state )
	  MedTopic.apply_vocab_delta( delta )

    end
  end
end

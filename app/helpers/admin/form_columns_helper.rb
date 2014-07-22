module Admin::FormColumnsHelper
  def affiliate_agency_form_column(record, options)
    agency_options = Agency.all.collect do |agency|
      name = if agency && agency.federal_register_agency
               "#{agency.name} (FRA: #{agency.federal_register_agency.name}:#{agency.federal_register_agency.id})"
             else
               agency.name
             end

      [name, agency.id]
    end

    select :record, :agency, agency_options, options.merge(include_blank: '- select -', selected: record.agency_id)
  end
end

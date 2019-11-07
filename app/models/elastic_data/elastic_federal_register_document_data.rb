# frozen_string_literal: true

class ElasticFederalRegisterDocumentData
  attr_reader :document

  def initialize(federal_register_document)
    @document = federal_register_document
  end

  def to_builder
    Jbuilder.new do |json|
      json.(document,
            :comments_close_on,
            :document_number,
            :federal_register_agency_ids,
            :id,
            :publication_date,
            :significant,
            :document_type)
      json.group_id(document.docket_id || document.document_number)
      %w[title abstract].each do |field|
        json.set! "#{field}.en", document.send(field)
      end
    end
  end
end

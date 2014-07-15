module FederalRegisterDocumentData
  def self.import(options = { load_all: false })
    fr_agencies = FederalRegisterAgency.active.to_a
    fr_agencies.each { |fra| fra.touch(:last_load_documents_requested_at) }
    fr_agencies.each { |fr_agency| load_documents(fr_agency, options) }
  end

  def self.load_documents(fr_agency, options = {})
    imported_document_ids = []
    parser_options = options.merge(federal_register_agency_id: fr_agency.id)
    parser = FederalRegisterDocumentApiParser.new parser_options

    parser.each_document do |document|
      imported_document = load_document document
      imported_document_ids << imported_document.id if imported_document
    end

    fr_agency.touch(:last_successful_load_documents_at)
    imported_document_ids
  rescue => error
    puts "Failed to load documents for FederalRegisterAgency #{fr_agency.id} #{error.backtrace.join("\n")}"
    imported_document_ids
  end

  def self.load_document(doc_attrs)
    fr_doc = FederalRegisterDocument.where(document_number: doc_attrs[:document_number]).first_or_initialize
    fr_doc.assign_attributes doc_attrs.except(:federal_register_agency_ids)

    FederalRegisterDocument.transaction do
      fr_doc.federal_register_agency_ids = doc_attrs[:federal_register_agency_ids]
      fr_doc if fr_doc.save
    end
  end
end

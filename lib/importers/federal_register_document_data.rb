module FederalRegisterDocumentData
  def self.import
    current_document_ids = FederalRegisterDocument.pluck :id
    imported_document_ids = load_documents

    obsolete_document_ids = current_document_ids - imported_document_ids
    FederalRegisterDocument.destroy obsolete_document_ids if imported_document_ids.present?
    imported_document_ids.count
  end

  def self.load_documents(options = {})
    imported_document_ids = []
    parser = FederalRegisterDocumentApiParser.new options

    parser.each_document do |document|
      imported_document = load_document document
      imported_document_ids << imported_document.id if imported_document
    end
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

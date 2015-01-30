class ElasticFederalRegisterDocumentData
  def initialize(federal_register_document)
    @federal_register_document = federal_register_document
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@federal_register_document, :abstract, :comments_close_on, :document_number,
        :federal_register_agency_ids, :id, :publication_date, :title, :significant, :document_type)
      json.group_id @federal_register_document.docket_id? ? @federal_register_document.docket_id : @federal_register_document.document_number
    end
  end

end

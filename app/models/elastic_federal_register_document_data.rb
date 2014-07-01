class ElasticFederalRegisterDocumentData
  def initialize(federal_register_document)
    @federal_register_document = federal_register_document
  end

  def to_builder
    Jbuilder.new do |json|
      if @federal_register_document.comments_close_on && @federal_register_document.comments_close_on >= Date.current
        comments_close_on = @federal_register_document.comments_close_on
      else
        comments_close_on = Date.current.advance(years: 2)
      end

      json.(@federal_register_document, :abstract, :document_number, :federal_register_agency_ids, :id, :title)
      json.comments_close_on comments_close_on
    end
  end

end

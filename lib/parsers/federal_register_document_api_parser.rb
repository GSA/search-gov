class FederalRegisterDocumentApiParser
  DEFAULT_PER_PAGE = 1000

  COLLECTION_FIELDS = [:agencies].freeze

  DATE_FIELDS = [:comments_close_on,
                 :effective_on,
                 :publication_date].freeze

  NUMBER_FIELDS = [:end_page,
                    :page_length,
                    :start_page].freeze

  STRING_FIELDS = [:abstract,
                   :document_number,
                   :html_url,
                   :title,
                   :type].freeze

  FIELDS = (COLLECTION_FIELDS + DATE_FIELDS + NUMBER_FIELDS + STRING_FIELDS).freeze

  def initialize(options = {})
    @federal_register_agency_ids = options[:federal_register_agency_ids] || FederalRegisterAgency.active.pluck(:id)
    @per_page = options[:per_page] || DEFAULT_PER_PAGE
  end

  def each_document
    @federal_register_agency_ids.each do |agency_id|
      each_agency_document(agency_id) do |document|
        yield document
      end
    end
  end

  def each_agency_document(agency_id)
    params = { conditions: { agency_ids: [agency_id] },
               fields: FIELDS,
               per_page: @per_page }
    results = FederalRegister::Article.search params
    results.each { |document| yield sanitize_document(document) }
  end

  private

  def sanitize_document(document)
    attributes = document.attributes.symbolize_keys
    sanitized_attributes = attributes.slice *NUMBER_FIELDS

    non_date_attributes = sanitize_attribute_values(attributes, DATE_FIELDS) do |value|
      Date.parse(value) rescue nil
    end
    sanitized_attributes.merge! non_date_attributes

    sanitized_attributes.merge! sanitize_attribute_values(attributes, STRING_FIELDS)

    document_type = sanitized_attributes.delete :type
    sanitized_attributes[:document_type] = document_type

    sanitized_attributes[:federal_register_agency_ids] = extract_agency_ids attributes

    sanitized_attributes
  end

  def sanitize_attribute_values(attributes, keys)
    sanitized_attributes = attributes.slice(*keys).keys.map do |key|
      value = attributes[key]
      value = value.present? ? value.squish : nil
      value = yield value if block_given?
      [key, value]
    end
    Hash[sanitized_attributes]
  end

  def extract_agency_ids(attributes)
    attributes[:agencies].map { |agency| agency['id'] }.sort
  end
end

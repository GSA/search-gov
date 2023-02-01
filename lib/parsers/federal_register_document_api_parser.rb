class FederalRegisterDocumentApiParser
  DEFAULT_PER_PAGE = 100

  COLLECTION_FIELDS = %w(agencies).freeze

  DATE_FIELDS = %w(comments_close_on effective_on publication_date).freeze

  NUMBER_FIELDS = %w(end_page page_length start_page).freeze

  BOOLEAN_FIELDS = %w(significant).freeze

  STRING_FIELDS = %w(abstract docket_id document_number html_url title type).freeze

  FIELDS = (COLLECTION_FIELDS + DATE_FIELDS + NUMBER_FIELDS + STRING_FIELDS + BOOLEAN_FIELDS).freeze

  def initialize(options = {})
    @federal_register_agency_id = options[:federal_register_agency_id]
    @per_page = options[:per_page] || DEFAULT_PER_PAGE
    @load_all = options[:load_all]
  end

  def each_document
    conditions = { agency_ids: [@federal_register_agency_id] }
    conditions[:publication_date] = { gte: Date.current.advance(days: -7) } unless @load_all

    params = { conditions: conditions,
               fields: FIELDS,
               order: :newest,
               per_page: @per_page }
    results = FederalRegister::Article.search params
    while results do
      results.each { |document| yield sanitize_document(document) }
      results = results.next
    end
  end

  private

  def sanitize_document(document)
    attributes = document.attributes
    sanitized_attributes = attributes.slice *(NUMBER_FIELDS + BOOLEAN_FIELDS)

    non_date_attributes = sanitize_attribute_values(attributes, DATE_FIELDS) do |value|
      Date.parse(value) rescue nil
    end
    sanitized_attributes.merge! non_date_attributes

    sanitized_attributes.merge! sanitize_attribute_values(attributes, STRING_FIELDS)

    document_type = sanitized_attributes.delete 'type'
    sanitized_attributes['document_type'] = document_type

    sanitized_attributes['federal_register_agency_ids'] = extract_agency_ids attributes

    sanitized_attributes.symbolize_keys
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
    attributes['agencies'].pluck('id').compact.uniq.sort
  end
end

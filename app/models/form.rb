class Form < ActiveRecord::Base
  DETAIL_FIELD_NAMES = [:description, :file_size, :number_of_pages, :landing_page_url, :revision_date, :links].freeze
  attr_accessible :form_agency_id, :number, :url, :file_type, :verified, :abstract, :title
  validates_presence_of :form_agency_id, :number, :url, :file_type, :title
  serialize :details, Hash
  belongs_to :form_agency
  has_and_belongs_to_many :indexed_documents

  DETAIL_FIELD_NAMES.each do |name|
    define_method name do
      send(:details).send("[]", name)
    end

    define_method :"#{name}=" do |arg|
      send(:details).send("[]=", name, arg)
    end
  end

  searchable do
    integer :form_agency_id
    text :number, :stored => true, :boost => 17.0, :as => 'number_text_form'
    text :title, :stored => true, :boost => 8.0, :as => 'title_text_form'
    text :description, :stored => true
    text :abstract
    boolean :verified
    string :line_of_business
    string :subfunction
    string :public_code
    string :file_type
  end

  class << self
    include QueryPreprocessor
  end

  def self.search_for(query, options = {})
    sanitized_query = preprocess(query).to_s.gsub(/\bforms?\b/i, '').strip

    ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model => self.name, :term => sanitized_query, :options => options}) do
      begin
        search do
          with(:form_agency_id, options[:form_agencies]) if options[:form_agencies].present?
          with(:verified, options[:verified]) if options.include?(:verified)
          with(:line_of_business, options[:line_of_business]) if options[:line_of_business].present?
          with(:subfunction, options[:subfunction]) if options[:subfunction].present?
          with(:public_code, options[:public_code]) if options[:public_code].present?
          with(:file_type, options[:file_type]) if options[:file_type].present?
          if sanitized_query.present?
            fulltext sanitized_query do
              highlight :number, :title, :frag_list_builder => 'single'
              highlight :description, :fragment_size => 255
            end
          end
          paginate :page => 1, :per_page => (options[:count] || 100)
        end
      rescue RSolr::Error::Http => e
        Rails.logger.warn "Error Form.search_for: #{e.to_s}"
        nil
      end
    end
  end
end

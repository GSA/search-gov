class Form < ActiveRecord::Base
  DETAIL_FIELD_NAMES = [:description, :file_size, :number_of_pages, :revision_date, :links].freeze
  attr_accessible :form_agency_id, :number, :url, :file_type, :verified, :abstract, :title, :landing_page_url
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

  scope :has_landing_page, where("landing_page_url IS NOT NULL")
  scope :verified, where(:verified => true)

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

    def govbox_search_for(query, form_agency_ids)
      if fulltext_form_search_eligible?(query)
        search_for(query, {:form_agencies => form_agency_ids, :verified => true, :count => 1})
      else
        form_results = verified.where('title = ? AND form_agency_id IN (?)', query.squish, form_agency_ids).limit(1)[0, 1]
        Struct.new(:total, :hits, :results).new(form_results.count, nil, form_results)
      end
    end

    def search_for(query, options = {})
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

    def sayt_for(affiliate_id, query, limit)
      form_agency_ids = Affiliate.find(affiliate_id).form_agency_ids rescue []
      return [] if form_agency_ids.empty?

      has_landing_page.verified.
        select(%w(title landing_page_url number)).
        where(:form_agency_id => form_agency_ids).
        where('landing_page_url IS NOT NULL AND title LIKE ?', "#{query}%").
        order('number ASC, title ASC').
        limit(limit)
    end

    private

    def fulltext_form_search_eligible?(query)
      query =~ /[[:digit:]]/i or query =~ /\bforms?\b/i && query.gsub(/\bforms?\b/i, '').strip.present?
    end

  end
end

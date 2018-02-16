class FederalRegisterDocument < ActiveRecord::Base
  has_and_belongs_to_many :federal_register_agencies, join_table: :federal_register_agencies_federal_register_documents

  validates_presence_of :document_number,
                        :document_type,
                        :end_page,
                        :html_url,
                        :page_length,
                        :publication_date,
                        :start_page,
                        :title

  validates_uniqueness_of :document_number, case_sensitive: false

  def contributing_agency_names
    parent_ids = federal_register_agencies.collect(&:parent_id).compact.uniq
    federal_register_agencies.reject do |fr_agency|
      parent_ids.include? fr_agency.id
    end.collect(&:name).sort
  end
end

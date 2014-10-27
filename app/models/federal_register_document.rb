class FederalRegisterDocument < ActiveRecord::Base
  attr_accessible :abstract,
                  :comments_close_on,
                  :docket_id,
                  :document_number,
                  :document_type,
                  :effective_on,
                  :end_page,
                  :html_url,
                  :page_length,
                  :publication_date,
                  :start_page,
                  :title

  has_and_belongs_to_many :federal_register_agencies

  validates_presence_of :document_number,
                        :document_type,
                        :end_page,
                        :html_url,
                        :page_length,
                        :publication_date,
                        :start_page,
                        :title

  validates_uniqueness_of :document_number, case_sensitive: false
end

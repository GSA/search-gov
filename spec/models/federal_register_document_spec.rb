require 'spec_helper'

describe FederalRegisterDocument do
  fixtures :federal_register_agencies, :federal_register_documents

  it { should have_and_belong_to_many :federal_register_agencies }

  it { should validate_presence_of :document_number }
  it { should validate_presence_of :document_type }
  it { should validate_presence_of :end_page }
  it { should validate_presence_of :html_url }
  it { should validate_presence_of :page_length }
  it { should validate_presence_of :publication_date }
  it { should validate_presence_of :start_page }
  it { should validate_presence_of :title }

  it { should validate_uniqueness_of :document_number }
end

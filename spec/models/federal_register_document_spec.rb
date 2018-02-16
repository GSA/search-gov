require 'spec_helper'

describe FederalRegisterDocument do
  fixtures :federal_register_agencies, :federal_register_documents

  it { is_expected.to have_and_belong_to_many :federal_register_agencies }

  it { is_expected.to validate_presence_of :document_number }
  it { is_expected.to validate_presence_of :document_type }
  it { is_expected.to validate_presence_of :end_page }
  it { is_expected.to validate_presence_of :html_url }
  it { is_expected.to validate_presence_of :page_length }
  it { is_expected.to validate_presence_of :publication_date }
  it { is_expected.to validate_presence_of :start_page }
  it { is_expected.to validate_presence_of :title }

  it { is_expected.to validate_uniqueness_of(:document_number).case_insensitive }
end

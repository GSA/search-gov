class FederalRegisterAgency < ActiveRecord::Base
  belongs_to :parent, class_name: 'FederalRegisterAgency'
  has_many :agencies
  has_and_belongs_to_many :federal_register_documents, join_table: :federal_register_agencies_federal_register_documents

  before_validation do |record|
    AttributeProcessor.squish_attributes record,
                                         :name,
                                         :short_name,
                                         assign_nil_on_blank: true
  end

  validates_presence_of :id, :name

  scope :active, -> { joins(:agencies).uniq }

  def to_label
    "#{name} (#{id})"
  end

  def load_documents
    unless documents_fresh?
      Resque.enqueue_with_priority(:high, FederalRegisterDocumentLoader, id)
      touch :last_load_documents_requested_at
    end
  end

  def documents_fresh?
    last_load_documents_requested_at && last_load_documents_requested_at >= Date.current
  end
end

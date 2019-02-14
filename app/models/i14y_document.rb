# frozen_string_literal: true

# Represents Elasticsearch documents created via the I14y API
class I14yDocument
  include ActiveModel::Validations
  extend ActiveModel::Callbacks

  class I14yDocumentError < StandardError; end

  define_model_callbacks :save

  delegate :i14y_connection, to: :i14y_drawer

  attr_accessor :document_id, :title, :path, :created, :description, :content,
                :changed, :promote, :language, :tags, :handle, :click_count

  validates_presence_of :document_id, :path, :handle, :title

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.create(attributes)
    doc = new(attributes)
    doc.save
    doc
  end

  def save
    run_callbacks :save do
      params = attributes.reject { |_k, v| v.blank? }
      response = i14y_connection.post self.class.api_endpoint, params
      raise I14yDocumentError.new(response.body.developer_message) unless response.status == 201

      true
    end
  end

  def self.update(attributes)
    doc = new(attributes)
    doc.update
  end

  def i14y_drawer
    @i14y_drawer ||= I14yDrawer.find_by_handle(handle)
  end
  alias_method :drawer, :i14y_drawer

  def attributes
    attributes = {}
    %i[document_id title path created description content
       changed promote language tags click_count].each do |attribute|
        attributes[attribute] = send(attribute)
    end
    attributes
  end

  def self.api_endpoint
    '/api/v1/documents'
  end

  def update
    params = attributes.except(:document_id).reject { |_k, v| v.blank? }
    response = i14y_connection.put "#{self.class.api_endpoint}/#{document_id}", params
    raise I14yDocumentError.new(response.body.developer_message) unless response.status == 200

    true
  end

  def self.delete(handle:, document_id:)
    doc = new(handle: handle, document_id: document_id)
    doc.delete
  end

  def delete
    response = i14y_connection.delete "#{self.class.api_endpoint}/#{document_id}"
    raise I14yDocumentError.new(response.body.developer_message) unless response.status == 200

    true
  end

  def self.promote(handle:, document_id:, bool: 'true')
    update(handle: handle, document_id: document_id, promote: bool)
  end
end

class I14yDocument
  include ActiveModel::Validations
  extend ActiveModel::Callbacks

  class I14yDocumentError < StandardError; end

  define_model_callbacks :save

  delegate :i14y_connection, to: :i14y_drawer

  attr_accessor :document_id, :title, :path, :created, :description, :content,
    :changed, :promote, :language, :tags, :handle

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
      params = attributes.reject{ |_k,v| v.blank? }
      response = i14y_connection.post self.class.api_endpoint, params
      raise I14yDocumentError.new(response.body.developer_message) unless response.status == 201
      true
    end
  end

  def i14y_drawer
    @i14y_drawer ||= I14yDrawer.find_by_handle(handle)
  end
  alias_method :drawer, :i14y_drawer

  def attributes
    attributes = {}
    [:document_id, :title, :path, :created, :description, :content,
     :changed, :promote, :language, :tags].each do |attribute|
        attributes[attribute] = send(attribute)
    end
    attributes
  end

  def self.api_endpoint
    "/api/v1/documents".freeze
  end
end

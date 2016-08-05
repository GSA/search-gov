class Api::DocsSearchOptions < Api::CommercialSearchOptions
  AZURE_HOSTED_PASSWORD = YAML.load_file("#{Rails.root}/config/hosted_azure.yml")[Rails.env]['account_key'].freeze
  attr_accessor :dc

  validates_presence_of :dc,
                        message: 'must be present'

  def initialize(params = {})
    super(params.reverse_merge(api_key: AZURE_HOSTED_PASSWORD))
    self.dc = params[:dc]
  end

  def attributes
    super.merge({dc: dc})
  end
end

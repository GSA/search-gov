class HostedAzureWebEngine < AzureWebEngine
  AZURE_HOSTED_PASSWORD = YAML.load_file("#{Rails.root}/config/hosted_azure.yml")[Rails.env]['account_key'].freeze

  def initialize(options)
    super options.merge(enable_highlighting: true,
                        language: options[:affiliate].locale,
                        limit: options[:per_page],
                        next_offset_within_limit: true,
                        password: AZURE_HOSTED_PASSWORD)
  end

  def parse_search_engine_response(response)
    super do |search_response|
      search_response.start_record = offset + 1
      search_response.end_record = search_response.start_record + search_response.results.size - 1
      assign_fake_total search_response
    end
  end

  protected

  def mashify(result)
    Hashie::Mash.new(content: result.description,
                     title: result.title,
                     unescaped_url: result.url)
  end

  def assign_fake_total(response)
    return unless response && response.results

    if response.next_offset
      response.total = response.next_offset + 1
    else
      response.total = @params.offset + response.results.count
    end
  end
end

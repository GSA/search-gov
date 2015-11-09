class HostedAzureWebEngine < AzureWebEngine
  def initialize(options)
    super options.merge! limit: options[:per_page],
                         next_offset_within_limit: true
  end

  def parse_search_engine_response(response)
    search_response = super
    assign_fake_total search_response
    search_response
  end

  protected

  def mashify(result)
    Hashie::Mash.new(content: result.description,
                     title: result.title,
                     unescaped_url: result.url)
  end

  def assign_fake_total(search_response)
    if search_response.next_offset
      search_response.total = search_response.next_offset + 1
    else
      search_response.total = @azure_params.offset + search_response.results.count
    end
  end
end

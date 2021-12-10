module DataGenerator
  class IndexAdapter
    attr_reader :site_handle
    attr_reader :search

    def initialize(site_handle, search)
      @site_handle = site_handle
      @search = search
    end

    def index_search_and_clicks
      indices.each do |index|
        es.index({
          index: index,
          type: 'search',
          body: {
            '@version' => 1,
            '@timestamp' => search.timestamp.iso8601,
            type: 'search',
            modules: search.modules,
            params: {
              affiliate: site_handle,
              query: search.query,
            },
          },
        })

        search.clicks.each do |click|
          es.index({
            index: index,
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => search.timestamp.iso8601,
              type: 'click',
              modules: search.modules,
              params: {
                affiliate: site_handle,
                query: search.query,
                url: click.url,
                position: click.position,
              },
            },
          })
        end
      end
    end

    private

    def indices
      suffix = search.timestamp.strftime('%Y.%m.%d')
      indices = search.is_human ? ["human-logstash-#{suffix}", "logstash-#{suffix}"] : ["logstash-#{suffix}"]
    end

    def es
      Es.client_writers.first
    end
  end
end

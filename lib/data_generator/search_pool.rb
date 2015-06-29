module DataGenerator
  Search = Struct.new(:timestamp, :is_human, :modules, :query, :clicks)
  Click = Struct.new(:url, :position)

  class SearchPool
    attr_reader :variation_count
    attr_reader :results_per_search
    attr_reader :clicks_per_search
    attr_reader :fake

    def initialize(variation_count, results_per_search, clicks_per_search, fake)
      @variation_count = variation_count
      @results_per_search = results_per_search
      @clicks_per_search = clicks_per_search
      @fake = fake
    end

    def search_session
      timestamp = fake.timestamp
      is_human = fake.is_human?
      modules = fake.modules
      query = results_by_query.keys.sample
      clicks = results_by_query[query].sample(clicks_per_search)

      Search.new(timestamp, is_human, modules, query, clicks)
    end

    private

    def results_by_query
      @results_by_query ||= begin
        queries_and_their_results = variation_count.times.map do
          [fake.search_query, random_results]
        end

        Hash[queries_and_their_results]
      end
    end

    def random_results
      results_per_search.times.map { |n| Click.new(fake.url, n + 1) }
    end
  end
end

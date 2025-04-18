module DataGenerator
  class Fake
    attr_reader :start_date
    attr_reader :end_date
    attr_reader :human_probability_pct

    def initialize(start_date, end_date, human_probability_pct, modules)
      @start_date = start_date
      @end_date = end_date
      @human_probability_pct = human_probability_pct
      @modules = modules
    end

    def timestamp
      Faker::Time.between(start_date.beginning_of_day, end_date.end_of_day, :all).utc
    end

    def search_query
      Faker::Lorem.words(4).join(' ')
    end

    def url
      Faker::Internet.url
    end

    def is_human?
      random.rand(100) < human_probability_pct
    end

    def modules
      [@modules.sample]
    end

    private

    def random
      @random ||= Random.new
    end
  end
end

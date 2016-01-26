module SearchConsumer
  module Entities
    class RssSearch < Grape::Entity
      expose :next_offset do |instance|
        if instance.total > 0
          next_offset = instance.startrecord + instance.per_page
          next_offset >= instance.total ? nil : next_offset
        end
      end
      expose :total, as: :count, documentation: { type: String, desc: "Search results total count." }
      expose :results, documentation: { type: 'Array', desc: 'Search Results.'}
    end
  end
end
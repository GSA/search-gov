module SearchConsumer
  module Entities
    class SearchPageAlert < Grape::Entity
      expose :status, documentation: { type: 'string', desc: 'Alert Status'}
      expose :text, documentation: { type: 'string', desc: 'Alert Text'}
      expose :title, documentation: { type: 'string', desc: 'Alert Title'}
    end
  end
end
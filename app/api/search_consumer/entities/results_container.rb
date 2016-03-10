module SearchConsumer
  module Entities
    class ResultsContainer < Grape::Entity
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to Page Wide Defaults'} do |affiliate|
        affiliate.template.load_schema.css.colors.results_container.to_hash
      end
    end
  end
end

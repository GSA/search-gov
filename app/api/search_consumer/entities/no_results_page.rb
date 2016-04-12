module SearchConsumer
  module Entities
    class NoResultsPage < Grape::Entity
      expose :additional_guidance_text, as: "additionalGuidanceText", documentation: { type: 'string', desc: 'Additional Guidance Text'}
      expose :managed_no_results_pages_alt_links, as: "altLinks", documentation: { type: 'string', desc: 'Alternative Links for No Results Message'}
    end
  end
end
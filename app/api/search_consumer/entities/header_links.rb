module SearchConsumer
  module Entities
    class HeaderLinks < Grape::Entity
      expose :managed_header_links, as: "links", documentation: { type: 'array', desc: 'Expose an array of objects containing Header link information.'}
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.template.load_schema.css.colors.header_links.to_hash
      end
    end
  end
end
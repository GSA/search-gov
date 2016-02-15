module SearchConsumer
  module Entities
    class Footer < Grape::Entity
      expose :managed_footer_links, as: "links", documentation: { type: 'array', desc: 'Expose an array of objects containing Footer link information.'}
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.load_template_schema.css.colors.footer.to_hash
      end
    end
  end
end
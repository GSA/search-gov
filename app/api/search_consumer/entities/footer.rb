module SearchConsumer
  module Entities
    class Footer < Grape::Entity
      expose :managed_footer_links, as: "links", documentation: { type: 'array', desc: 'Expose an array of objects containing Footer link information.'}
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.load_template_schema.css.colors.footer.to_hash
      end
      expose :page_one_more_results_pointer, documentation: { type: 'string', desc: 'Text directing the user to additional search results' }
      expose :footer_fragment, documentation: { type: 'string', desc: 'Custom footer text (may contain HTML tags)' }
    end
  end
end

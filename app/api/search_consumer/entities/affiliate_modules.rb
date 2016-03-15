module SearchConsumer
  module Entities
    class AffiliateModules < Grape::Entity
      expose :is_rss_govbox_enabled, as: :rss_govbox, documentation: { type: 'boolean', desc: 'TRUE if rss govbox results should show.'}
      expose :rss_govbox_label, if: lambda{|instance,opts| instance.is_rss_govbox_enabled }, documentation: { type: 'string', desc: 'The RSS Combined Govbox Label'}
      expose :is_video_govbox_enabled, as: :video, documentation: { type: 'boolean', desc: 'TRUE if video results should show.'}
      expose :jobs_enabled, as: :job_openings, documentation: { type: 'boolean', desc: 'TRUE if jobs results should show.'}
      expose :is_federal_register_document_govbox_enabled, as: :federal_register_documents, documentation: { type: 'boolean', desc: 'TRUE if federal register docs results should show.'}
      expose :is_related_searches_enabled, as: :related_searches, documentation: { type: 'boolean', desc: 'TRUE if related searches results should show.'}
      expose :is_medline_govbox_enabled, as: :health_topics, documentation: { type: 'boolean', desc: 'TRUE if health topics should show.'}
      expose :is_sayt_enabled, as: :typeahead_search, documentation: { type: 'boolean', desc: 'TRUE if typeahead results should show.'}
    end
  end
end
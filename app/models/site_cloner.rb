class SiteCloner
  attr_reader :target_handle, :target_display_name

  DO_NOT_COPY = [:id, :api_access_key, :created_at, :updated_at, :has_staged_content, :name, :display_name,
                 :previous_fields_json, :staged_fields_json, :live_fields_json,
                 :staged_uses_managed_header_footer, :keen_scoped_key, :nutshell_id]

  def initialize(origin_site, target_handle = nil)
    @origin_site = origin_site
    @target_handle = assign_target_handle(target_handle)
    @target_display_name = "#{@origin_site.display_name} (Copy)"
  end

  def clone
    new_attrs = { name: @target_handle, display_name: @target_display_name }
    attrs = @origin_site.as_json(except: DO_NOT_COPY).to_hash.merge(new_attrs)

    cloned_site = Affiliate.create!(attrs)

    cloned_site.users << @origin_site.users

    clone_site_domains(cloned_site)

    clone_rss_feeds(cloned_site)

    clone_document_collections(cloned_site)

    cloned_site.twitter_profile_ids = @origin_site.twitter_profile_ids

    cloned_site.youtube_profile_ids = @origin_site.youtube_profile_ids

    cloned_site.enable_video_govbox!

    clone_boosted_contents(cloned_site)

    clone_featured_collections(cloned_site)

    clone_i14y_memberships(cloned_site)

    cloned_site
  end

  def clone_i14y_memberships(cloned_site)
    @origin_site.i14y_memberships.each do |i14y_membership|
      cloned_site.i14y_memberships.create!(i14y_drawer: i14y_membership.i14y_drawer)
    end
  end

  def clone_featured_collections(cloned_site)
    @origin_site.featured_collections.each do |fc|
      cloned_fc = cloned_site.featured_collections.build(title: fc.title,
                                                         title_url: fc.title_url,
                                                         publish_start_on: fc.publish_start_on,
                                                         publish_end_on: fc.publish_end_on,
                                                         image_alt_text: fc.image_alt_text,
                                                         status: fc.status,
                                                         created_at: fc.created_at,
                                                         updated_at: fc.updated_at)
      fc.featured_collection_keywords.each do |keyword|
        cloned_fc.featured_collection_keywords.build(value: keyword.value)
      end

      fc.featured_collection_links.each do |link|
        cloned_fc.featured_collection_links.build(title: link.title,
                                                  url: link.url,
                                                  position: link.position)
      end
      cloned_fc.save!
    end
  end

  def clone_boosted_contents(cloned_site)
    @origin_site.boosted_contents.each do |bc|
      cloned_bc = cloned_site.boosted_contents.build(title: bc.title,
                                                     url: bc.url,
                                                     description: bc.description,
                                                     publish_start_on: bc.publish_start_on,
                                                     publish_end_on: bc.publish_end_on,
                                                     status: bc.status,
                                                     created_at: bc.created_at,
                                                     updated_at: bc.updated_at)
      cloned_bc.save!
      bc.boosted_content_keywords.each do |keyword|
        # create because not all keywords are valid
        cloned_bc.boosted_content_keywords.create(value: keyword.value)
      end
    end
  end

  def clone_document_collections(cloned_site)
    @origin_site.document_collections.each do |dc|
      cloned_dc = cloned_site.document_collections.build(name: dc.name)
      dc.url_prefixes.each do |url_prefix|
        cloned_dc.url_prefixes.build(prefix: url_prefix.prefix)
      end
      cloned_dc.save!(validate: false)
    end
  end

  def clone_rss_feeds(cloned_site)
    @origin_site.rss_feeds.non_managed.each do |rss_feed|
      cloned_feed = cloned_site.rss_feeds.build(name: rss_feed.name,
                                                show_only_media_content: rss_feed.show_only_media_content,
                                                rss_feed_urls: rss_feed.rss_feed_urls)
      cloned_feed.save!(validate: false)
    end
  end

  def clone_site_domains(cloned_site)
    @origin_site.site_domains.each do |site_domain|
      cloned_site.site_domains.create! domain: site_domain.domain
    end
  end

  private

  def assign_target_handle(target_handle)
    @target_handle = target_handle || available_handle_from(@origin_site.name)
  end

  def available_handle_from(existing_handle)
    possibly_shortened_handle = existing_handle.first(Affiliate::MAX_NAME_LENGTH - 1)
    candidate = "#{possibly_shortened_handle}1"
    while Affiliate.exists?(name: candidate)
      candidate.succ!
    end
    candidate
  end
end
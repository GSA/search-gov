class SiteCloner
  attr_reader :target_handle, :target_display_name

  def initialize(origin_site, target_handle = nil)
    @origin_site = origin_site
    @target_handle = assign_target_handle(target_handle)
    @target_display_name = "Copy of #{@origin_site.display_name}"
  end

  def clone
    assign_unique_navigation_positions @origin_site

    cloned_site = create_site_shallow_copy

    clone_simple_associations cloned_site
    clone_boosted_contents cloned_site
    clone_document_collections cloned_site
    clone_featured_collections cloned_site
    clone_flickr_profiles cloned_site
    clone_image_search_label cloned_site
    clone_routed_queries cloned_site
    clone_rss_feeds cloned_site
    clone_site_feed_url cloned_site
    clone_images cloned_site

    cloned_site.instagram_profile_ids = @origin_site.instagram_profile_ids
    cloned_site.youtube_profile_ids = @origin_site.youtube_profile_ids

    clone_memberships cloned_site

    cloned_site
  end

  def create_site_shallow_copy
    dup = @origin_site.dup
    dup.assign_attributes display_name: @target_display_name,
                          name: @target_handle
    dup.save!
    dup
  end

  def clone_simple_associations(cloned_site)
    clone_associations @origin_site,
                       cloned_site,
                       :affiliate_twitter_settings,
                       :connections,
                       :excluded_urls,
                       :i14y_memberships,
                       :indexed_documents,
                       :site_domains,
                       :affiliate_templates
  end

  def clone_image_search_label(cloned_site)
    origin_label = @origin_site.image_search_label
    cloned_label = cloned_site.image_search_label
    cloned_label.update_attributes!(name: origin_label.name)
    copy_navigation_attributes origin_label.navigation, cloned_label.navigation
  end

  def clone_boosted_contents(cloned_site)
    clone_association_with_children @origin_site,
                                    cloned_site,
                                    :boosted_contents,
                                    :boosted_content_keywords
  end

  def clone_document_collections(cloned_site)
    @origin_site.document_collections.each do |dc|
      cloned_dc = dc.dup
      clone_associations dc, cloned_dc, :url_prefixes
      cloned_site.document_collections << cloned_dc

      copy_navigation_attributes dc.navigation, cloned_dc.navigation
    end
  end

  def clone_featured_collections(cloned_site)
    clone_association_with_children @origin_site,
                                    cloned_site,
                                    :featured_collections,
                                    :featured_collection_keywords,
                                    :featured_collection_links
  end

  def clone_flickr_profiles(cloned_site)
    @origin_site.flickr_profiles.map(&:dup).each do |cloned_fp|
      cloned_fp.affiliate = cloned_site
      cloned_fp.save(validate: false)
    end
  end

  def clone_memberships(cloned_site)
    clone_associations @origin_site, cloned_site, :memberships
  end

  def clone_routed_queries(cloned_site)
    ActiveRecord::Base.observers.disable :routed_query_keyword_observer

    clone_association_with_children @origin_site,
                                    cloned_site,
                                    :routed_queries,
                                    :routed_query_keywords
  ensure
    ActiveRecord::Base.observers.enable :routed_query_keyword_observer
  end

  def clone_rss_feeds(cloned_site)
    @origin_site.rss_feeds.each do |rss_feed|
      cloned_feed = rss_feed.dup
      cloned_feed.rss_feed_urls = rss_feed.rss_feed_urls
      cloned_site.rss_feeds << cloned_feed

      copy_navigation_attributes rss_feed.navigation, cloned_feed.navigation
    end
  end

  def clone_site_feed_url(cloned_site)
    cloned_site.site_feed_url = @origin_site.site_feed_url.dup if @origin_site.site_feed_url
  end

  def clone_images(cloned_site)
    cloned_site.page_background_image = @origin_site.page_background_image if @origin_site.page_background_image.file?
    cloned_site.header_image = @origin_site.header_image if @origin_site.header_image.file?
    cloned_site.mobile_logo = @origin_site.mobile_logo if @origin_site.mobile_logo.file?
    cloned_site.header_tagline_logo = @origin_site.header_tagline_logo if @origin_site.header_tagline_logo.file?
    cloned_site.save
  end

  private

  def assign_unique_navigation_positions(site)
    site.navigations.each_with_index do |nav, index|
      nav.update_attributes! position: index
    end
  end

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

  def clone_association_with_children(origin_model, cloned_model, association, *child_associations)
    origin_model.send(association).each do |parent_model|
      cloned_parent_model = parent_model.dup
      child_associations.each do |child_association|
        clone_associations parent_model, cloned_parent_model, child_association
      end
      cloned_model.send(association).send(:'<<', cloned_parent_model)
    end
  end

  def clone_associations(origin_model, cloned_model, *associations)
    associations.each do |association|
      dups = origin_model.send(association).map(&:dup)
      cloned_model.send :"#{association}=", dups
    end
  end

  def copy_navigation_attributes(source_nav, cloned_nav)
    nav_attributes = source_nav.attributes.slice('is_active', 'position')
    cloned_nav.update_attributes! nav_attributes
  end
end

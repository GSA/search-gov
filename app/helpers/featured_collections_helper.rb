module FeaturedCollectionsHelper
  def featured_collection_links_list(fc)
    if fc.has_two_column_layout?
      links_size = fc.featured_collection_links.size
      left_links_size = (links_size / 2) + (links_size % 2)

      [fc.featured_collection_links.slice(0, left_links_size),
       fc.featured_collection_links.slice(left_links_size, links_size - left_links_size)]
    else
      [fc.featured_collection_links]
    end
  end

  def featured_collection_title(fc)
    link_to_if fc.title_url.present?, fc.title, fc.title_url, target: '_blank'
  end

  def featured_collection_keywords_item(fc)
    best_bets_keywords_items(fc.featured_collection_keywords) if fc.featured_collection_keywords.present?
  end

  def link_to_add_new_featured_collection_link(title, site, fc)
    instrumented_link_to title, new_link_site_best_bets_graphics_path(site), fc.featured_collection_links.length, 'link'
  end

  def featured_collection_css_classes(featured_collection, initial_classes = %w(featured-collection searchresult))
    css_classes = initial_classes
    css_classes << featured_collection.layout.parameterize
    (css_classes << 'with-image') if featured_collection.image_file_name.present?
    css_classes.join(' ')
  end

  def render_featured_collection_image(fc)
    content = []
    content << image_tag(fc.image.url(fc.has_one_column_layout? ? :medium : :small), :alt => fc.image_alt_text)
    unless fc.image_attribution.blank?
      content << content_tag(:span, I18n.t(:image))
      content << link_to_unless(fc.image_attribution_url.blank?, content_tag(:span, fc.image_attribution, :class => 'attribution'), fc.image_attribution_url)
    end
    content_tag(:div, content.join("\n").html_safe, :class => 'image')
  rescue Exception
    nil
  end

  def featured_collection_class_hash(fc)
    classes = %w(featured-collection)
    classes << 'has-image' if fc.image_file_name.present?
    classes << 'two-column' if fc.has_two_column_layout?
    { class: classes }
  end

  def featured_collection_image(fc)
    if fc.image_file_name.present?
      content = image_tag(fc.image.url(:medium), alt: fc.image_alt_text)
      content_tag(:div, content, class: 'image')
    end
  rescue => e
    Rails.logger.warn e
    nil
  end

  def featured_collection_content_trigger_class_hash(best_bets_count, fc)
    links_count = fc.featured_collection_links.count
    return {} if best_bets_count <= 2 and links_count <= 4

    classes = []
    classes << 'has-collapsed-featured-collection' if best_bets_count > 2
    classes << (links_count <= 4 ? 'one-column-hide-trigger' : 'one-column-show-trigger')
    classes << 'two-column-hide-trigger' if fc.has_two_column_layout? and links_count <= 8
    classes.present? ? { class: classes } : {}
  end
end

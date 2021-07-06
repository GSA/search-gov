module FeaturedCollectionsHelper
  MAX_LINKS_SHOW_PER_LIST_ON_COLLAPSED = 5.freeze
  ONE_COLUMN_SHOW_BOTH_LINKS_LIST_THRESHOLD = ((MAX_LINKS_SHOW_PER_LIST_ON_COLLAPSED * 2) - 2).freeze
  TWO_COLUMN_HIDE_TRIGGER_THRESHOLD = (MAX_LINKS_SHOW_PER_LIST_ON_COLLAPSED * 2).freeze

  def featured_collection_links_list(fc)
    links_size = fc.featured_collection_links.size
    left_links_size = (links_size / 2) + (links_size % 2)

    [fc.featured_collection_links.to_a.slice(0, left_links_size),
     fc.featured_collection_links.to_a.slice(left_links_size, links_size - left_links_size)]
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

  def featured_collection_class_hash(fc)
    classes = %w(featured-collection)
    classes << 'has-image' if fc.image_file_name.present?
    links_count = fc.featured_collection_links.count
    classes << 'one-column-show-both-links-list' if links_count <= ONE_COLUMN_SHOW_BOTH_LINKS_LIST_THRESHOLD
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
    return {} if best_bets_count <= 2 and links_count <= MAX_LINKS_SHOW_PER_LIST_ON_COLLAPSED

    classes = []
    classes << 'has-collapsed-featured-collection' if best_bets_count > 2
    classes << (links_count <= 5 ? 'one-column-hide-trigger' : 'one-column-show-trigger')
    classes << 'two-column-hide-trigger' if links_count <= TWO_COLUMN_HIDE_TRIGGER_THRESHOLD
    classes.present? ? { class: classes } : {}
  end
end

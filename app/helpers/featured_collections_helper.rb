module FeaturedCollectionsHelper
  def featured_collection_title(fc)
    link_to_if fc.title_url.present?, fc.title, fc.title_url, target: '_blank'
  end

  def featured_collection_keywords_item(fc)
    best_bets_keywords_items(fc.featured_collection_keywords) if fc.featured_collection_keywords.present?
  end

  def link_to_add_new_featured_collection_link(title, site, fc)
    instrumented_link_to title, new_link_site_best_bets_graphics_path(site), fc.featured_collection_links.length, 'link'
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
end

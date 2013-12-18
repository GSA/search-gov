module FeaturedCollectionsHelper
  def featured_collection_title(fc)
    link_to_if fc.title_url.present?, fc.title, fc.title_url, target: '_blank'
  end

  def featured_collection_keywords_item(fc)
    return unless fc.featured_collection_keywords.present?
    content = content_tag(:span, 'Keywords: ', class: 'description')
    keyword_items = fc.featured_collection_keywords.map do |keyword|
      content_tag :li, keyword.value, class: 'label'
    end
    content << content_tag(:ul, keyword_items.join.html_safe, class: 'keywords')
    content_tag :li, content.html_safe
  end

  def link_to_add_new_featured_collection_link(title, site, fc)
    link_to title,
            new_link_site_best_bets_graphics_path(site),
            remote: true,
            data: { params: { index: fc.featured_collection_links.length } },
            id: 'new-link-trigger'
  end

  def featured_collection_link_with_click_tracking(title, url, affiliate, query, position, vertical, model_id)
    return title if url.blank?
    link_with_click_tracking(title, url, affiliate, query, position, 'BBG', vertical, model_id)
  end

  def featured_collection_css_classes(featured_collection, initial_classes = %w(featured-collection searchresult))
    css_classes = initial_classes
    css_classes << featured_collection.layout.parameterize
    (css_classes << 'with-image') if featured_collection.image_file_name.present?
    css_classes.join(' ')
  end

  def render_featured_collection_link_title(link, index, highlighted_link_titles)
    return h(link.title) if highlighted_link_titles.blank? or highlighted_link_titles[index].blank?
    highlighted_link_titles[index].html_safe
  end

  def render_featured_collection_image(fc)
    begin
      unless fc.image_file_name.blank?
        content = []
        content << image_tag(fc.image.url(fc.has_one_column_layout? ? :medium : :small), :alt => fc.image_alt_text)
        unless fc.image_attribution.blank?
          content << content_tag(:span, I18n.t(:image))
          content << link_to_unless(fc.image_attribution_url.blank?, content_tag(:span, fc.image_attribution, :class => 'attribution'), fc.image_attribution_url)
        end
        content_tag(:div, content.join("\n").html_safe, :class => 'image')
      end
    rescue Exception
      nil
    end
  end

  def featured_collection_class_hash(fc)
    classes = %w(featured-collection)
    classes << 'has-image' if fc.image_file_name.present?
    { class: classes }
  end

  def featured_collection_image(fc)
    begin
      if fc.image_file_name.present?
        content = image_tag(fc.image.url(:medium), alt: fc.image_alt_text)
        content_tag(:div, content, class: 'image')
      end
    rescue => e
      Rails.logger.warn e
      nil
    end
  end

  def featured_collection_link_titles(hit)
    if hit.highlights(:link_titles).present?
      highlight_hit(hit, :link_titles).split(FeaturedCollection::LINK_TITLE_SEPARATOR).map do |title|
        title.html_safe
      end
    else
      hit.instance.featured_collection_links.map { |link| h(link.title) }
    end
  end

  def rearrange_featured_collection_links_indices(links_size)
    left_links_size = (links_size / 2) + (links_size % 2)
    left_links_size.times.map do |i|
      [i, i + left_links_size]
    end.flatten.slice(0, links_size)
  end

  def featured_collection_content_trigger_class_hash(best_bets_count, fc)
    links_count = fc.featured_collection_links.count
    return {} if best_bets_count <= 2 and links_count <= 4

    classes = []
    classes << 'has-collapsed-featured-collection' if best_bets_count > 2
    classes << 'one-column-hide-trigger' if links_count <= 4
    classes << 'two-column-hide-trigger' if fc.has_two_column_layout? and links_count <= 8
    classes.present? ? { class: classes } : {}
  end
end

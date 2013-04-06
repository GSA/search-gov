module FeaturedCollectionsHelper
  def featured_collection_link_with_click_tracking(title, url, affiliate, query, position, vertical)
    return title if url.blank?
    link_with_click_tracking(title, url, affiliate, query, position, 'BBG', vertical)
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

end

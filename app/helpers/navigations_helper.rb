# frozen_string_literal: true

module NavigationsHelper
  def filter_navigations(navigations)
    items = navigations.to_a
    items.reject! do |n|
      n.navigable.is_a?(RssFeed) && n.navigable.show_only_media_content?
    end
    items.reject { |n| n.navigable.is_a?(ImageSearchLabel) }
  end

  def link_to_navigable_facet_type(nav)
    case nav.navigable_facet_type
    when 'DocumentCollection'
      link_to('Collection', edit_site_collection_path(nav.navigable.affiliate, nav.navigable))
    when 'ImageSearchLabel'
      build_image_search_navigable_label nav.navigable
    end
  end

  def build_image_search_navigable_label(navigable)
    labels = +''
    site = navigable.affiliate
    labels.html_safe
  end

  def append_navigation_label(labels, label)
    labels << raw('/') unless labels.blank?
    labels << label
  end

  def render_navigable_field_name_for(navigation)
    navigation.navigable.instance_of?(ImageSearchLabel) ? navigation.navigable_type.underscore : navigation.navigable_type.underscore.pluralize
  end
end

module DocumentCollectionsHelper
  def link_to_view_collection_url_prefixes(site, collection)
    title = content_tag(:h1, collection.name)
    link_to collection.name,
            site_collection_path(site, collection.id),
            class: 'modal-page-viewer-link',
            data: { modal_container: '#url-prefixes',
                    modal_title: title,
                    modal_content_selector: '.url-prefixes' }
  end

  def link_to_preview_collection(site, collection)
    link_to 'Preview',
            docs_search_url(protocol: 'http',
                            affiliate: site.name,
                            dc: collection.id,
                            query: 'gov'),
            target: '_blank'
  end

  def list_item_with_button_to_remove_collection(site, collection)
    path = site_collection_path site, collection.id
    data = { confirm: "Are you sure you wish to remove #{collection.name} from this site?" }
    button = button_to 'Remove', path, method: :delete, data: data, class: 'btn btn-small'
    content_tag :li, button
  end
end

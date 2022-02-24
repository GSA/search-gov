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
    params = { affiliate: site.name, dc: collection.id, query: 'government' }
    url = docs_search_url(params)
    link_to 'Preview', url, target: '_blank'
  end

  def list_item_with_button_to_remove_collection(site, collection)
    path = site_collection_path site, collection.id
    message = "Are you sure you wish to remove #{collection.name} from this site?"
    list_item_with_button_to_remove(path, message)
  end
end

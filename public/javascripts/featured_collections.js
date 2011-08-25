jQuery(document).ready(function() {
  jQuery('#add_another_keyword').click(function() {

    var inputTagFormat =
        "<tr class='row-item'>\
          <td>\
            <input id='featured_collection_featured_collection_keywords_attributes_#_value' name='featured_collection[featured_collection_keywords_attributes][#][value]' maxlength='255' type='text' />\
          </td>\
        </tr>";
    var inputTag = inputTagFormat.replace(/#/g, new Date().getTime());
    jQuery('.keywords table tbody').append(inputTag);
    jQuery('.keywords input').last().focus();
    return false;
  });

  jQuery('#add_another_link').click(function() {
    position = parseInt(jQuery('.links .position').last().attr('value')) + 1;
    var inputTagFormat =
      "<tr class='row-item'>\
        <td>\
          <input class='position' id='featured_collection_featured_collection_links_attributes_#_position' name='featured_collection[featured_collection_links_attributes][#][position]' type='hidden' value='{pos}' />\
          <input class='title' id='featured_collection_featured_collection_links_attributes_#_title' maxlength='255' name='featured_collection[featured_collection_links_attributes][#][title]' type='text' />\
        </td>\
        <td>\
          <input class='url' id='featured_collection_featured_collection_links_attributes_#_url' maxlength='255' name='featured_collection[featured_collection_links_attributes][#][url]' type='text' />\
        </td>\
      </tr>";
    var inputTag = inputTagFormat.replace(/#/g, new Date().getTime()).replace(/{pos}/g, position);
    jQuery('.links table tbody').append(inputTag);
    jQuery('.links .title').last().focus();
    return false;
  });

  jQuery('.add-featured-collection #featured_collection_title').focus();
});


function setupDragAndDropOnFeaturedCollectionLinks() {
  jQuery('.links table').tableDnD({ onDragClass: 'ondrag' });
}

jQuery(document).ready(function() {
  jQuery('.sliding_trigger').click(function() {
    var collapsedPattern = /^\+/;
    var slidingContentId = "#" + jQuery(this).attr("id") + "_content";
    var content = jQuery(this).html();

    if (collapsedPattern.test(content)) {
      jQuery(slidingContentId).slideDown('fast');
      content = content.replace("+", "-");
    } else {
      jQuery(slidingContentId).slideUp('fast');
      content = content.replace("-", "+");
    }
    jQuery(this).html(content);
    return false;
  });

  jQuery('.sliding_content').each(function() {
    if (jQuery(this).hasClass('expand')) {
      var slidingContentId = jQuery(this).attr("id");
      var slidingTriggerId = slidingContentId.replace(/\_content$/, "");
      jQuery('#' + slidingTriggerId).trigger('click');
      location.href = '#' + slidingContentId;
    }
  });

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

  jQuery('#add_another_bc_keyword').click(function() {

    var inputTagFormat =
        "<tr class='row-item'>\
          <td>\
            <input id='boosted_content_boosted_content_keywords_attributes_#_value' name='boosted_content[boosted_content_keywords_attributes][#][value]' maxlength='255' type='text' />\
          </td>\
        </tr>";
    var inputTag = inputTagFormat.replace(/#/g, new Date().getTime());
    jQuery('.keywords table tbody').append(inputTag);
    jQuery('.keywords input').last().focus();
    return false;
  });

  jQuery('#add_another_url_prefix').click(function() {
    var inputTagFormat =
        "<tr class='row-item'>\
          <td>\
            <input id='document_collection_url_prefixes_attributes_#_prefix' name='document_collection[url_prefixes_attributes][#][prefix]' maxlength='255' type='text' />\
          </td>\
        </tr>";
    var inputTag = inputTagFormat.replace(/#/g, new Date().getTime());
    jQuery('.url-prefixes table tbody').append(inputTag);
    jQuery('.url-prefixes input').last().focus();
    return false;
  });

  jQuery('.add-featured-collection #add_another_link, .edit-featured-collection #add_another_link').click(function() {
    position = parseInt(jQuery('.links .position').last().attr('value')) + 1;
    var inputTagFormat =
      "<tr class='row-item'>\
        <td class='title'>\
          <input class='position' id='featured_collection_featured_collection_links_attributes_#_position' name='featured_collection[featured_collection_links_attributes][#][position]' type='hidden' value='{pos}' />\
          <input class='title' id='featured_collection_featured_collection_links_attributes_#_title' maxlength='255' name='featured_collection[featured_collection_links_attributes][#][title]' type='text' />\
        </td>\
        <td class='url'>\
          <input class='url' id='featured_collection_featured_collection_links_attributes_#_url' maxlength='255' name='featured_collection[featured_collection_links_attributes][#][url]' type='text' />\
        </td>\
      </tr>";
    var inputTag = inputTagFormat.replace(/#/g, new Date().getTime()).replace(/{pos}/g, position);
    jQuery('.links table tbody').append(inputTag);
    jQuery('.links .title').last().focus();
    setupDragAndDropOnFeaturedCollectionLinks();
    return false;
  });

  jQuery('.add-featured-collection #featured_collection_title').focus();
  setupDragAndDropOnFeaturedCollectionLinks();
  jQuery('.add-featured-collection, .edit-featured-collection').submit(function() {
    jQuery('.links .position').each(function(index) {
      jQuery(this).val(index);
    });
    return true;
  });

  var currentErrorMessageDialogId = null;

  jQuery('.url-error-message').each(function() {
    jQuery(this).dialog({
      autoOpen: false,
      dialogClass: 'url-error-message-dialog',
      modal: true,
      stack: false,
      title: 'Last Crawl Error Message',
      minWidth: 512 });
  });

  jQuery('.ui-widget-overlay').live('click', function() {
    jQuery(currentErrorMessageDialogId).dialog('close');
  });

  jQuery('.dialog-link').each(function() {
    jQuery(this).click(function() {
      var dialogId = jQuery(this).attr('dialog_id');
      currentErrorMessageDialogId = '#' + dialogId;
      jQuery(currentErrorMessageDialogId).dialog('open');
      return false;
    });
  });
});

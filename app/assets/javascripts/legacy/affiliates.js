function enableOrDisableColorFields(theme) {
  if (theme == 'custom')
    jQuery('.css-overrides input.color').prop('disabled', false);
  else
    jQuery('.css-overrides input.color').prop('disabled', true);
}

function updateColorFields(cssProperties) {
  document.getElementById('affiliate_staged_css_property_hash_page_background_color').color.fromString(cssProperties.page_background_color);
  document.getElementById('affiliate_staged_css_property_hash_content_background_color').color.fromString(cssProperties.content_background_color);
  document.getElementById('affiliate_staged_css_property_hash_search_button_text_color').color.fromString(cssProperties.search_button_text_color);
  document.getElementById('affiliate_staged_css_property_hash_search_button_background_color').color.fromString(cssProperties.search_button_background_color);
  document.getElementById('affiliate_staged_css_property_hash_left_tab_text_color').color.fromString(cssProperties.left_tab_text_color);
  document.getElementById('affiliate_staged_css_property_hash_title_link_color').color.fromString(cssProperties.title_link_color);
  document.getElementById('affiliate_staged_css_property_hash_visited_title_link_color').color.fromString(cssProperties.visited_title_link_color);
  document.getElementById('affiliate_staged_css_property_hash_description_text_color').color.fromString(cssProperties.description_text_color);
  document.getElementById('affiliate_staged_css_property_hash_url_link_color').color.fromString(cssProperties.url_link_color);
}

function enableHeaderFooterFields(option) {
  var $enabled, $disabled;
  if (option === 'managed') {
    $enabled = jQuery('.header-footer-fields.managed');
    $disabled = jQuery('.header-footer-fields.custom');
  } else {
    $enabled = jQuery('.header-footer-fields.custom');
    $disabled = jQuery('.header-footer-fields.managed');
  }
  $disabled.children('input, textarea').prop('disabled', true);
  $disabled.hide();
  $enabled.children('input, textarea').prop('disabled', false);
  $enabled.show();
}

function setupDragAndDropOnManagedLinks(option) {
  if (option == 'header') {
    jQuery('.header-links table').each(function() {
      jQuery(this).tableDnD({ onDragClass: 'ondrag' });
    });
  } else {
    jQuery('.footer-links table').each(function() {
      jQuery(this).tableDnD({ onDragClass: 'ondrag' });
    });
  }
}

function setupConnections() {
  jQuery('.connections table').each(function() {
    jQuery(this).tableDnD({ onDragClass: 'ondrag' });
  });
  jQuery(".remove-connection").click(function(event) {
    event.preventDefault();
    jQuery(this).siblings('input.destroy-connection').val('1');
    jQuery(this).parents('tr.row-item.connection').hide();
  });
}

function setupRssForm() {
  jQuery(".rss-form .remove-url").click(function(event) {
    event.preventDefault();
    jQuery(this).siblings('input.destroy-url').prop('checked', true);
    jQuery(this).parents('tr.row-item.url').hide();
  });
}

function generateValidationHtml(source) {
  var prefix = "<!DOCTYPE html>\n<html>\n<head>\n<title>\n</title>\n</head>\n<body>\n<div id='container'>\n";
  var textAreaWrapper = "<div id='" + source + "'>\n";
  var textAreaValue = jQuery('#affiliate_staged_' + source).val();
  var suffix = "</div>\n</div>\n</body>\n</html>\n";
  return prefix + textAreaWrapper + textAreaValue + suffix;
}

jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/" + jQuery('#affiliate_id').val());
  });
  jQuery('#embed_code_textarea_en, #embed_code_textarea_es, #embed_stats_code_textarea').click(function() {
    this.focus();
    this.select();
  });

  jQuery(".theme input[type='radio']").click(function() {
    var theme = jQuery(this).parent().children('input.update-css-properties-trigger').val();
    if (theme != 'custom') {
      jQuery(".hidden-custom-theme").slideUp('fast');
      var css_properties = jQuery.parseJSON(jQuery(this).parent().attr('data'));
      if (css_properties != null)
        updateColorFields(css_properties);
    }
    enableOrDisableColorFields(theme);
  });

  jQuery('.css-properties-image-trigger').click(function() {
    jQuery(this).siblings('input.update-css-properties-trigger').trigger('click');
  });

  jQuery("input[checked][value='custom']").each(function() {
    enableOrDisableColorFields('custom');
  });

  jQuery(".customize-theme-button").click(function() {
    var cssProperties = jQuery.parseJSON(jQuery(this).parent().attr('data'));
    updateColorFields(cssProperties);
    var theme = jQuery(this).parent().children('input.update-css-properties-trigger').val();
    enableOrDisableColorFields('custom');
    jQuery(".hidden-custom-theme").slideDown('fast');
    var customRadioButton =  jQuery("input.update-css-properties-trigger[value='custom']");
    customRadioButton.prop('checked', true);
    customRadioButton.focus();
  });

  jQuery(".managed-header-footer-option:checked").each(function() {
    enableHeaderFooterFields('managed');
  });
  jQuery(".custom-header-footer-option:checked").each(function() {
    enableHeaderFooterFields('custom');
  });
  jQuery(".managed-header-footer-option").click(function() {
    enableHeaderFooterFields('managed');
  });
  jQuery(".custom-header-footer-option").click(function() {
    enableHeaderFooterFields('custom');
  });

  jQuery(".header-footer-form").submit(function() {
    jQuery(".header-links .position").each(function(index) {
      jQuery(this).val(index);
    });
    jQuery(".footer-links .position").each(function(index) {
      jQuery(this).val(index);
    });
  });
  setupDragAndDropOnManagedLinks('header');
  setupDragAndDropOnManagedLinks('footer');

  jQuery(".sidebar-form .sidebar-items table").each(function() {
    jQuery(this).tableDnD({ onDragClass: 'ondrag' });
    jQuery(".sidebar-form").submit(function() {
      jQuery(".sidebar-form .position").each(function(index) {
        jQuery(this).val(index);
      });
    });
  });

  jQuery(".results-modules-form").submit(function() {
    jQuery(".connections .position").each(function(index) {
      jQuery(this).val(index);
    });
  });

  setupConnections();
  setupRssForm();

  jQuery('#validate_header_link').click(function(event) {
    event.preventDefault();
    jQuery('#content').val(generateValidationHtml('header'));
    jQuery('#validator_form').submit();
    return false;
  });

  jQuery('#validate_footer_link').click(function(event) {
    event.preventDefault();
    jQuery('#content').val(generateValidationHtml('footer'));
    jQuery('#validator_form').submit();
    return false;
  });
});

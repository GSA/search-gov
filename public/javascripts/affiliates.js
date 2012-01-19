function enableOrDisableColorFields(theme) {
  if (theme == 'custom')
    jQuery('.css-overrides input.color').removeAttr('disabled');
  else
    jQuery('.css-overrides input.color').attr('disabled', 'disabled');
}

function updateColorFields(cssProperties) {
  document.getElementById('affiliate_staged_css_property_hash_search_button_text_color').color.fromString(cssProperties.search_button_text_color);
  document.getElementById('affiliate_staged_css_property_hash_search_button_background_color').color.fromString(cssProperties.search_button_background_color);
  document.getElementById('affiliate_staged_css_property_hash_left_tab_text_color').color.fromString(cssProperties.left_tab_text_color);
  document.getElementById('affiliate_staged_css_property_hash_title_link_color').color.fromString(cssProperties.title_link_color);
  document.getElementById('affiliate_staged_css_property_hash_visited_title_link_color').color.fromString(cssProperties.visited_title_link_color);
  document.getElementById('affiliate_staged_css_property_hash_description_text_color').color.fromString(cssProperties.description_text_color);
  document.getElementById('affiliate_staged_css_property_hash_url_link_color').color.fromString(cssProperties.url_link_color);
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
    customRadioButton.attr('checked', 'checked');
    customRadioButton.focus();
  });
});


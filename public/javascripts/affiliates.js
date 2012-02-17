function enableOrDisableColorFields(theme) {
  if (theme == 'custom')
    jQuery('.css-overrides input.color').removeAttr('disabled');
  else
    jQuery('.css-overrides input.color').attr('disabled', 'disabled');
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

function enableHeaderFooterForm(option) {
  if (option == 'managed') {
    jQuery('.header-footer-form.custom input, .header-footer-form.custom textarea').attr('disabled', 'disabled');
    jQuery('.header-footer-form.custom').hide();
    jQuery('.header-footer-form.managed').show();
    jQuery('.header-footer-form.managed input, .header-footer-form.managed textarea').removeAttr('disabled');
  } else {
    jQuery('.header-footer-form.managed input, .header-footer-form.managed textarea').attr('disabled', 'disabled');
    jQuery('.header-footer-form.managed').hide();
    jQuery('.header-footer-form.custom').show();
    jQuery('.header-footer-form.custom input, .header-footer-form.custom textarea').removeAttr('disabled');
  }
}

function enableLookAndFeelForm(option) {
  if (option == 'one-serp') {
    jQuery('.look-and-feel-form.legacy input, .look-and-feel-form.legacy select').attr('disabled', 'disabled');
    jQuery('.look-and-feel-form.legacy').hide();
    jQuery('.look-and-feel-form.one-serp').show();
    jQuery('.look-and-feel-form.one-serp input').removeAttr('disabled');
  } else {
    jQuery('.look-and-feel-form.one-serp input, .look-and-feel-form.one-serp select').attr('disabled', 'disabled');
    jQuery('.look-and-feel-form.one-serp').hide();
    jQuery('.look-and-feel-form.legacy').show();
    jQuery('.look-and-feel-form.legacy input').removeAttr('disabled');
  }
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

  jQuery(".managed-header-footer-option:checked").each(function() {
    enableHeaderFooterForm('managed');
  });
  jQuery(".custom-header-footer-option:checked").each(function() {
    enableHeaderFooterForm('custom');
  });
  jQuery(".managed-header-footer-option").click(function() {
    enableHeaderFooterForm('managed');
  });
  jQuery(".custom-header-footer-option").click(function() {
    enableHeaderFooterForm('custom');
  });

  jQuery(".one-serp-look-and-feel-option:checked").each(function() {
    enableLookAndFeelForm('one-serp');
  });
  jQuery(".legacy-look-and-feel-option:checked").each(function() {
    enableLookAndFeelForm('legacy');
  });
  jQuery(".one-serp-look-and-feel-option").click(function() {
    enableLookAndFeelForm('one-serp');
  });
  jQuery(".legacy-look-and-feel-option").click(function() {
    enableLookAndFeelForm('legacy');
  });
});


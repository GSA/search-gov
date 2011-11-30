jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/" + jQuery('#affiliate_id').val());
  });
  jQuery('#embed_code_textarea_en, #embed_code_textarea_es').click(function() {
    this.focus();
    this.select();
  });

  jQuery('.update_css_properties_trigger').click(function() {
    var css_properties = jQuery.parseJSON(jQuery(this).parent().attr('data'));

    document.getElementById('affiliate_staged_css_property_hash_left_tab_text_color').color.fromString(css_properties.left_tab_text_color);
    document.getElementById('affiliate_staged_css_property_hash_link_color').color.fromString(css_properties.link_color);
    document.getElementById('affiliate_staged_css_property_hash_visited_link_color').color.fromString(css_properties.visited_link_color);
    document.getElementById('affiliate_staged_css_property_hash_hover_link_color').color.fromString(css_properties.hover_link_color);
    document.getElementById('affiliate_staged_css_property_hash_description_text_color').color.fromString(css_properties.description_text_color);
    document.getElementById('affiliate_staged_css_property_hash_url_link_color').color.fromString(css_properties.url_link_color);
    document.getElementById('affiliate_staged_css_property_hash_visited_url_link_color').color.fromString(css_properties.visited_url_link_color);
    document.getElementById('affiliate_staged_css_property_hash_hover_url_link_color').color.fromString(css_properties.hover_url_link_color);
    return false;
  });
});


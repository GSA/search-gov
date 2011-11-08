jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/" + jQuery('#affiliate_id').val());
  });
  jQuery('#embed_code_textarea_en, #embed_code_textarea_es').click(function() {
    this.focus();
    this.select();
  });
});


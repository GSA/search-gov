jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/" + jQuery('#affiliate_id').val());
  });
  jQuery('#formatting_tips_link').click(function() {
    var collapsedPattern = /^\+/;
    var content = jQuery('#formatting_tips_link').html();
    if (collapsedPattern.test(content)) {
      jQuery('#formatting_tips').slideDown('fast');
      content = content.replace("+", "-");
    } else {
      jQuery('#formatting_tips').slideUp('fast');
      content = content.replace("-", "+");
    }
    jQuery('#formatting_tips_link').html(content);
    return false;
  })
});

jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/" + jQuery('#affiliate_id').val());
  });

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
  })
});

jQuery(document).ready(function() {
  jQuery('#affiliate_id').change(function(event) {
    window.location.replace("/affiliates/home?status=sel&said=" + jQuery('#affiliate_id').val());
  });
});

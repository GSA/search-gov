(function($) {
  $.fn.multiSites = function() {
    this.each(function() {
      var searchForm = this;
      $(this).children('input[affiliate]').click(function() {
        var affiliate = $(this).attr('affiliate');
        $(searchForm).children('input[name="affiliate"]').first().val(affiliate);
        $(searchForm).submit();
      });
    });
  }
})(jQuery);

jQuery(function() {
  jQuery('#search_form').multiSites();
});

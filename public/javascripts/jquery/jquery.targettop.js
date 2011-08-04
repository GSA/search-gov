(function($) {
    $.fn.targetTop = function() {
      this.each(function(index) {
        jQuery(this).attr('target', '_top');
      });
    }
})(jQuery);
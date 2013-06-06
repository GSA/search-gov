(function($) {
    $.fn.simplePopup = function(options) {
        this.click(function() {
            window.open(this.href, '_blank', options);
            return false;
        });
    }
})(jQuery);
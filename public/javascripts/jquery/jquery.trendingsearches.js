function getWidgetSource(parent) {
  if (parent !== parent.parent)
    return getWidgetSource(parent.parent);
  else
    return parent.location.hostname;
}

function appendWidgetSourceToSearchString(link, widgetSource) {
  link.search = link.search + '&widget_source=' + encodeURIComponent(widgetSource);
}

(function($) {
  $.fn.appendWidgetSourceParameter = function() {
    if ((widgetSource != null) && (widgetSource != ''))
      return;
    var widgetHostname = document.location.hostname;
    widgetSource = getWidgetSource(window.parent);
    var pathnamePattern = /^\/?search/i;
    this.each(function() {
      var query = this.search.substring(1);
      if ((widgetHostname != this.hostname) || !pathnamePattern.test(this.pathname) || query == '')
        return;
      var pairs = query.split("&");
      if (pairs.length > 0)
        appendWidgetSourceToSearchString(this, widgetSource);
    });
  }
})(jQuery);

jQuery(document).ready(function() {
  jQuery('.trending-search-link').appendWidgetSourceParameter();
});

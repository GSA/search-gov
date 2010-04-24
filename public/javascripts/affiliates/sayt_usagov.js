var USAGovSearch = {};
USAGovSearch.url = function(url) {
  url = url + "&locale=" + (window.usagov_locale || "en");
  if (window.usagov_affiliate) {
    url = url + "&affiliate=" + window.usagov_affiliate;
  }
  return url;
};

USAGovSearch.selectUrl = function(value) {
  return this.url(window.usagov_select_url + value);
}

USAGovSearch.sourceUrl = function() {
  return this.url(window.usagov_source_url);
}

jQuery.noConflict();
(function($) {
  $(document).ready(function() {
    $("#usagov-search input[type=text]").autocomplete({
      minLength: 2,
      select: function(event, ui) {
        location.href = USAGovSearch.selectUrl(ui.item.value);
      },
      source: function(request, response) {
        $.ajax({
          url: USAGovSearch.sourceUrl(),
          data: { query: request.term },
          success: function(data) {
            var suggestions = $.map($(data).find('li'), function(item) {
              return { label: $(item).html(), value: $(item).text() };
            });
            response(suggestions);
          }
        });
      }
    });
  });
})(jQuery);
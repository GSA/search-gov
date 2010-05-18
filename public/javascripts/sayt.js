$(document).ready(function() {
  $("#usagov-search-field").autocomplete("http://searchdemo.usa.gov/searches/auto_complete_for_search_query", {
      max: 15,
      extraParams: {
          locale: "en",
          m: false,
          mode: "jquery"
      }
    }
  );
});
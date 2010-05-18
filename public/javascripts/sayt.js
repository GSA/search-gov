$(document).ready(function() {
  $("#usagov-search-field").autocomplete("http://searchdemo.usa.gov/searches/auto_complete_for_search_query", {
    dataType: "jsonp",
    parse: function(data) {
      var rows = new Array();
      for (var i = 0; i < data.length; i++) {
        rows[i] = {data:data[i], value:data[i], result:data[i]};
      }
      return rows;
    },
    formatItem: function(row, i, n) {
      return row;
    },
    max: 15,
    extraParams: {
      locale: "en",
      m: false,
      mode: "jquery"
    }
  });
});

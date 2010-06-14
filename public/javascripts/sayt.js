if (usagov_sayt_url === undefined) {
    var usagov_sayt_url = "http://search.usa.gov/sayt";
}

$(document).ready(function() {
  $(".usagov-search-autocomplete").autocomplete(usagov_sayt_url, {
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
    highlight: function(value, term) {
      return value.replace(term, "<strong class='highlight'>" + term + "</strong>");
    },
    scroll: false,
    max: 15,
    extraParams: {
      locale: "en",
      m: false,
      mode: "jquery"
    }
  }).result(function(event, data, formatted){
    $(this).parent().submit();
  });
});

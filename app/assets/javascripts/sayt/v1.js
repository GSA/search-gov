/* eslint-disable */
if (usagov_sayt_url === undefined) {
    var usagov_sayt_url = '';
}

$(document).ready(function() {
  if (usagov_sayt_url == '')
    return;
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
    delay: 50,
    minChars: 2,
    matchSubset: false,
    cacheLength: 50,
    max: 15,
    selectFirst: false
  }).result(function(event, data, formatted){
    $(this).closest('form').submit();
  });
});

if (document.images) {
  var img = new Image;
  img.src = ['http://stats.search.usa.gov/?','a=',affiliate,'&u=',encodeURIComponent(document.URL)].join('');
}

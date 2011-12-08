if (document.images) {
  var img = new Image;
  img.src = ['http://stats.search.usa.gov/?','a=',aid,'&u=',encodeURIComponent(document.URL)].join('');
}

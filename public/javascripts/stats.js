if (document.images) {
  var img = new Image;
  img.src = [document.location.protocol, '//stats.search.usa.gov/?','a=',aid,'&u=',encodeURIComponent(document.URL)].join('');
}

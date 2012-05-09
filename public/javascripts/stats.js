if (document.images) {
  var img = new Image;
  img.src = [document.location.protocol, '//searchstats.usa.gov/?','a=',aid,'&u=',encodeURIComponent(document.URL)].join('');
}

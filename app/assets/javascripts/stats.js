/* eslint-disable no-undef, no-var, prefer-const */
if (document.images) {
  var img = new Image;
  img.src = [document.location.protocol, '//stats.search.usa.gov/stats.gif?','a=',aid,'&u=',encodeURIComponent(document.URL)].join('');
}

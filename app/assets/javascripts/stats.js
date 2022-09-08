/* eslint-disable no-undef */
if (document.images) {
  let img = new Image;
  img.src = [document.location.protocol, '//stats.search.usa.gov/stats.gif?','a=',aid,'&u=',encodeURIComponent(document.URL)].join('');
}

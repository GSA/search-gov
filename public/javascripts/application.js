function click(query, url, serp_position, affiliate, source, queried_at) {
  if (document.images) {
    var img = new Image;
    params='u='+escape(url)+'&q='+escape(query)+'&p='+serp_position+'&a='+affiliate+'&s='+source+'&t='+queried_at
    img.src = '/click?'+ params
  }
  return true;
}

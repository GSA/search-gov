function clk(a, b, c, d, e, f) {
  if (document.images) {
    var img = new Image;
    img.src = ['/click?','u=',escape(b),'&q=',escape(a),'&p=',c,'&a=',d,'&s=',e,'&t=',f].join('');
  }
  return true;
}


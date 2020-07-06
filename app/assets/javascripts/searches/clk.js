// TO REMOVE SRCH-1525
function clk(a, b, c, d, e, f, g, h, i) {
  if (document.images) {
    var img = new Image;
    img.src = ['/clicked?','u=',encodeURIComponent(b),'&q=',encodeURIComponent(a),'&p=',c,'&a=',d,'&s=',e,'&t=',f,'&v=',g,'&l=',h,'&i=',i].join('');
  }
  return true;
}

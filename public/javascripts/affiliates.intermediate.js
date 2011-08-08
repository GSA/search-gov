var iframe;
var socket = new easyXDM.Socket({
  swf: "/javascripts/easyXDM/easyxdm.swf",
  onReady: function() {
    iframe = document.createElement('iframe');
    iframe.frameBorder = 0;
    iframe.scrolling = "no";
    document.body.appendChild(iframe);
    iframe.src = easyXDM.query.url;
  },
  onMessage: function(url, origin){
    iframe.src = url;
  }
});

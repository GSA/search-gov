
(function($) {
  $.fn.easyxdm = function(options) {

    var settings = {
      'remoteHost': 'search.usa.gov',
      'minWidth': 1000,
      'minHeight': 300
    };

    if (options) {
      $.extend(settings, options);
    }

    return this.each(function() {
      var query = location.search.substring(1) || "";
      var url = "http://" + settings.remoteHost + "/embedded_search.html?url=" + encodeURIComponent("/search?" + query);
      var swf = "http://" + settings.remoteHost + "/javascripts/easyXDM/easyxdm.swf";
      var containerId = $(this).attr('id');

      var transport = new easyXDM.Socket({
        remote: url,
        swf: swf,
        container: containerId,
        props: { scrolling: "no" },
        onMessage: function(message, origin){

          var dimensions = message.split(" ");
          var width = parseInt(dimensions[0]);
          if (width < settings.minWidth) {
            width = settings.minWidth;
          }

          var height = parseInt(dimensions[1]);
          if (height < settings.minHeight) {
            height = settings.minHeight;
          }

          this.container.getElementsByTagName("iframe")[0].style.width = width + "px";
          this.container.getElementsByTagName("iframe")[0].style.height = height + "px";
        }
      });
    });
  };

})(jQuery);


(function($) {
  $.fn.easyxdm = function(options) {

    var settings = {
      'remoteHost': 'search.usa.gov',
      'container': 'embedded',
      'minWidth': 970,
      'widthOffset': 0,
      'minHeight': 300,
      'heightOffset': 50
    };

    return this.each(function() {
      if (options) {
        $.extend(settings, options);
      }
      var query = location.search.substring(1) || "";
      var url = "http://" + settings.remoteHost + "/embedded_search?url=" + encodeURIComponent("/search?") + encodeURIComponent(query);
      var swf = "http://" + settings.remoteHost + "/javascripts/easyXDM/easyxdm.swf";
      var containerId = $(this).attr('id');

      var transport = new easyXDM.Socket({
        remote: url,
        swf: swf,
        container: containerId,
        onMessage: function(message, origin){

          var dimensions = message.split(" ");
          var width = parseInt(dimensions[0]);
          if (width < settings.minWidth) {
            width = settings.minWidth;
          } else {
            width += settings.widthOffset;
          }

          var height = parseInt(dimensions[1]);
          if (height < settings.minHeight) {
            height = settings.minHeight;
          } else {
            height += settings.heightOffset;
          }

          this.container.getElementsByTagName("iframe")[0].style.width = width + "px";
          this.container.getElementsByTagName("iframe")[0].style.height = height + "px";
        }
      });
    });
  };

})(jQuery);

function clk(a, b, c, d, e, f) {
  if (document.images) {
    var img = new Image;
    img.src = ['/clicked?','u=',encodeURIComponent(b),'&q=',escape(a),'&p=',c,'&a=',d,'&s=',e,'&t=',f].join('');
  }
  return true;
}

function getParameterByName( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

(function($) {
    $.fn.share = function() {
        this.click(function() {
            var addthis_pub = 'usagov';
            var addthis_clickout = true;
            var addthis_url =  location.href;
            var addthis_title = document.title;
            return addthis_click(this);
        });
    }
})(jQuery);

jQuery(document).ready(function() {
    jQuery('.share').share();
});

jQuery(document).ready(function () {	
	jQuery('.nav li').hover(
		function () {
			//show submenu
			jQuery('ul', this).slideDown(100);
		}, 
		function () {
			//hide submenu
			jQuery('ul', this).slideUp(100);			
		}
	);
});

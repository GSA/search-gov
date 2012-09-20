function clk(a, b, c, d, e, f, g, h) {
  if (document.images) {
    var img = new Image;
    img.src = ['/clicked?','u=',encodeURIComponent(b),'&q=',escape(a),'&p=',c,'&a=',d,'&s=',e,'&t=',f,'&v=',g,'&l=',h].join('');
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
    var shareLinks = this;
    $.getScript("https://s9.addthis.com/js/widget.php?v=10", function() {
      shareLinks.click(function() {
        var addthis_pub = 'usagov';
        var addthis_clickout = true;
        var addthis_url =  location.href;
        var addthis_title = document.title;
        return addthis_click(this);
      });
    });
  }
})(jQuery);

jQuery(document).ready(function() {
  jQuery('.share').each(function() {
    jQuery('.share').share();
  });
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

jQuery(document).ready(function () {
    jQuery('#search_query').change(function() {
        update_vertical_navigation_links(jQuery(this).attr('value'));
    });
});

function update_vertical_navigation_links(new_text) {
    jQuery('.updatable').each(function(){
        var re = new RegExp("query=" + original_query, "");
        jQuery(this).attr('href', jQuery(this).attr('href').replace(re, "query=" + new_text));
    });
    original_query = new_text;
}

function toggle_more_or_less_options() {
  var selector = '#left_column .options-wrapper .triangle';
  jQuery('#left_column #show_options, #left_column #hide_options').toggle();
  jQuery(selector).toggleClass('show-options');
  jQuery(selector).toggleClass('hide-options');
  jQuery('#left_column .time-filters-and-facets-wrapper').slideToggle();
}

function toggle_facets(element) {
  jQuery(element).children('.more-facets, .less-facets').toggle();
  jQuery(element).children('.triangle').toggleClass('show-options');
  jQuery(element).children('.triangle').toggleClass('hide-options');
  jQuery(element).closest('ul.facet').children('.collapsible').slideToggle();
}

jQuery(document).ready(function() {
  jQuery('.options-wrapper').click(function() {
    toggle_more_or_less_options();
  });
  jQuery('.more-facets-wrapper').click(function() {
    toggle_facets(this);
  });
});

jQuery(document).ready(function() {
  jQuery.infinitescroll.prototype._showdonemsg_usasearch = function() {

    var opts = this.options;
    opts.loading.msg
        .find('img')
        .hide()
        .parent()
        .find('div').html(opts.loading.finishedMsg).animate({ opacity:1 }, 1000);

    // user provided callback when done
    opts.errorCallback.call($(opts.contentSelector)[0], 'done');
  };

  jQuery.infinitescroll.prototype._determinepath_usasearch = function(path) {
    var opts = this.options;
    if (path.match(/^(.*?page=)\d+(.*?|$)/)) {
      path = path.match(/^(.*?page=)\d+(.*|$)/).slice(1);
    }
    return path;
  };

  jQuery.infinitescroll.prototype._loadcallback_usasearch = function(box, responseText) {

    var opts = this.options,
        callback = this.options.callback, // GLOBAL OBJECT FOR CALLBACK
        result = (opts.state.isDone) ? 'done' : (!opts.appendCallback) ? 'no-append' : 'append',
        frag,
        odieFrag,
        logos = ['bing', 'usasearch'],
        logo,
        currentLogo,
        odieDocs;

    switch (result) {

      case 'done':

        this._showdonemsg();
        return false;

        break;

      case 'append':

        var children = box.children();

        if (children.length == 0) {
          return this._error('end');
        }

        $(logos).each(function() {
          logo = this;
          if (box.children('.results-by-logo').hasClass(logo)) {
            currentLogo = logo;
            $('#results .pagination-and-logo').each(function() {
              if ($(this).children().hasClass(logo))
                $(this).remove();
            });
          }
        });
        box.children('.results-by-logo').wrap('<div class="pagination-and-logo" />');
        if (currentLogo == 'usasearch') {
          box.children('.searchresult').addClass('indexeddocresult');
          if ((currentLogo == 'usasearch') && ($('#indexed_documents').length == 0)) {
            box.children('.searchresult').wrapAll('<div id="indexed_documents" />');
          }
        }

        frag = document.createDocumentFragment();
        while (box[0].firstChild) {
          frag.appendChild(box[0].firstChild);
        }

        if (currentLogo == 'usasearch') {
          if ($('#results #indexed_documents').length == 0) {
            odieFrag = document.createDocumentFragment();
            var govbox = document.createElement('div');
            govbox.className = 'govbox';
            var wrappers = ['govbox-wrapper-top', 'govbox-wrapper-middle', 'govbox-wrapper-bottom'];
            for (var i = 0; i < wrappers.length; i++) {
              var wrapperElement = document.createElement('div');
              wrapperElement.className = wrappers[i];
              if (i == 1) {
                wrapperElement.appendChild(frag);
              }
              govbox.appendChild(wrapperElement);
            }
            odieFrag.appendChild(govbox);
            $(opts.contentSelector)[0].appendChild(odieFrag);
          } else {
            $('#results #indexed_documents')[0].appendChild(frag);
          }
        } else {
          $(opts.contentSelector)[0].appendChild(frag);
        }

        data = children.get();
        break;
    }

    opts.loading.finished.call($(opts.contentSelector)[0],opts)

    // smooth scroll to ease in the new content
    if (opts.animate) {
      var scrollTo = $(window).scrollTop() + $('#infscr-loading').height() + opts.extraScrollPx + 'px';
      $('html,body').animate({ scrollTop:scrollTo }, 800, function () {
        opts.state.isDuringAjax = false;
      });
    }

    if (!opts.animate) opts.state.isDuringAjax = false; // once the call is done, we can allow it again.

    callback(this,data);
  };

  jQuery('#results').infinitescroll( {
    navSelector: '#usasearch_pagination',
    nextSelector: '#usasearch_pagination a.next_page',
    itemSelector: '#results .searchresult, .results-by-logo',
    loading: {
      img: '/images/infinite_scroll/ajax_loader.gif',
      msgText: '',
      finishedMsg: '<a href="#main_content">Back to top</a>'
    },
    state: {
      currPage: jQuery('#usasearch_pagination .current').text()
    },
    bufferPx: 500,
    behavior: 'usasearch'
  });

  if ((jQuery('#usasearch_pagination').length > 0) && ($(document).height() <= $(window).height())) {
    jQuery('#results').infinitescroll('scroll');
  }
});

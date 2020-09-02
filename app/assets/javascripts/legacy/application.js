function clk(a, b, c, d, e, f, g, h, i) {
  // TO REMOVE SRCH-1525
  if (document.images) {
    var img = new Image;
    img.src = ['/clicked?','u=',encodeURIComponent(b),'&q=',encodeURIComponent(a),'&p=',c,'&a=',d,'&s=',e,'&t=',f,'&v=',g,'&l=',h,'&i=',i].join('');
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
      newValue = jQuery(this).val();
      update_vertical_navigation_links(newValue);
      jQuery('#left_column #cdr_query').val(newValue);
    });
});

function update_vertical_navigation_links(new_text) {
  var encodedQuery = encodeURIComponent(new_text);
  jQuery('.updatable').each(function () {
    var re = new RegExp("query=" + original_query, "");

    jQuery(this).attr('href', jQuery(this).attr('href').replace(re, "query=" + encodedQuery));
  });
  original_query = encodedQuery;
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

function load_image_spans(newsItems) {
  jQuery(newsItems).each(function() {
    jQuery(this).children('a').hover(
      function() {
        var item = jQuery(this).parent();
        var span = jQuery(this).children('span.host').first();
        if (! jQuery(span).hasClass('position-assigned')) {
          jQuery(span).position({
            my: 'left top',
            at: 'left top',
            of: item,
            collision: 'none'
          });
          jQuery(span).addClass('position-assigned');
        }
        jQuery(span).css({ width: item.innerWidth() - 10 });
        jQuery(span).show();
      },
      function() {
        var span = jQuery(this).children('span.host').first();
        jQuery(span).hide();
      }
    );
  });
}

jQuery(document).ready(function() {
  jQuery('.options-wrapper').click(function() {
    toggle_more_or_less_options();
  });
  jQuery('.more-facets-wrapper').click(function() {
    toggle_facets(this);
  });

  if (jQuery('#results .time-filters').length > 0) {
    var currentCdrField;
    var enOptions = { dateFormat: 'm/d/yy', maxDate: '+0d' };
    jQuery('.en #results #cdr_date_picker').datepicker(enOptions);

    var dayNamesMin = ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'];
    var monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
    var esOptions = { dateFormat: 'd/m/yy', monthNames: monthNames, dayNamesMin: dayNamesMin, maxDate: '+0d' };
    jQuery('.es #results #cdr_date_picker').datepicker(esOptions);

    jQuery('#results #cdr_since_date').focus(function() {
      currentCdrField = this;
      jQuery('#results #cdr_date_picker').datepicker('setDate', jQuery(this).val());
      jQuery('#results .from .date-wrapper').addClass('highlight');
      jQuery('#results .to .date-wrapper').removeClass('highlight');
      jQuery(this).select();
    });

    jQuery('#results #cdr_until_date').focus(function() {
      currentCdrField = this;
      jQuery('#results #cdr_date_picker').datepicker('setDate', jQuery(this).val());
      jQuery('#results .from .date-wrapper').removeClass('highlight');
      jQuery('#results .to .date-wrapper').addClass('highlight');
      jQuery(this).select();
    });

    jQuery('#results #cdr_date_picker').datepicker('option', 'onSelect', function(dateText, inst) {
      if (jQuery(currentCdrField).attr('id') == 'cdr_since_date') {
        jQuery('#results #cdr_since_date').val(dateText);
        jQuery('#results #cdr_until_date').focus();
      } else if (jQuery(currentCdrField).attr('id') == 'cdr_until_date') {
        jQuery('#results #cdr_until_date').val(dateText);
        jQuery('#results #cdr_until_date').focus();
      }
    });

    jQuery('#results .current-time-filter').click(function(event) {
      event.preventDefault();
      jQuery('#results ul.sort-filter-options').hide();
      jQuery('#results .current-sort-filter .triangle').addClass('show-options').removeClass('hide-options');
      jQuery('#results ul.time-filter-options').toggle();
      jQuery('#results .current-time-filter .triangle').toggleClass('show-options hide-options');
      return false;
    });

    jQuery(document).click(function(event) {
      jQuery('#results ul.time-filter-options, #results ul.sort-filter-options').hide();
      jQuery('#results .current-time-filter .triangle, #results .current-sort-filter .triangle').addClass('show-options').removeClass('hide-options');
    });

    jQuery('#results .current-sort-filter').click(function(event) {
      event.preventDefault();
      jQuery('#results ul.time-filter-options').hide();
      jQuery('#results .current-time-filter .triangle').addClass('show-options').removeClass('hide-options');
      jQuery('#results ul.sort-filter-options').toggle();
      jQuery('#results .current-sort-filter .triangle').toggleClass('show-options hide-options');
      return false;
    });

    jQuery('#results #custom_range').overlay({
      mask: {
        color: '#EFEFEF',
        loadSpeed: 200,
        opacity: 0.8
      },
      top: '35%',
      onLoad: function() {
        jQuery('#results #cdr_since_date').focus();
      }
    });

    jQuery('#results #cdr_search_form').submit(function(event) {
      jQuery('#results #custom_range').overlay().close();
    });
  }

  var footer = jQuery('#usasearch_footer');
  if ((footer.length) > 0) {
    var footerHeight = footer.outerHeight(true);
    if (footerHeight > 0) {
      if (!jQuery.support.transition || !jQuery.fn.transition)
        jQuery.fn.transition = jQuery.fn.animate;
      var footerHidden = true;
      var footerButton = jQuery('#usasearch_footer_button');
      footerButton.show();
      var containerWidth = jQuery('#container').innerWidth();
      footer.css({ margin: '0 auto', width: containerWidth });
      var footerContainer = jQuery('#usasearch_footer_container');
      footerButton.click(function(event) {
        event.preventDefault();
        if (footerHidden) {
          maxFooterHeight = Math.min(footerHeight, jQuery(window).outerHeight(true) - 40);
          footerContainer.transition({ height: maxFooterHeight });
          jQuery(this).html('&#9650;');
          jQuery(this).transition({ bottom: maxFooterHeight });
          jQuery(this).attr('title', jQuery(this).data('tooltip').hideText);
          footerHidden = false;
        } else {
          jQuery(this).transition({ bottom: 0 }, 300);
          jQuery(this).html('&#9660;');
          footerContainer.transition({ height: 0 }, 300);
          jQuery(this).attr('title', jQuery(this).data('tooltip').showText);
          footerHidden = true;
        }
      });
    }
  }
  if (jQuery('#results.media').length > 0) {
    load_image_spans(jQuery('.newsitem.image').toArray());
  }
});

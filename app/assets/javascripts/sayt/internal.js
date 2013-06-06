if (usagov_sayt_url === undefined) {
  var usagov_sayt_url = "http://search.usa.gov/sayt?";
}

function monkeyPatchAutocomplete() {
  var oldFn = jQuery.ui.autocomplete.prototype._renderItem;

  jQuery.ui.autocomplete.prototype._renderItem = function(ul, item) {
    var term;
    if (item.data) {
      // If it's a non-SaytSuggestion, highlight where the words start with a term
      var re = new RegExp('\\b' + this.term, "i");
      term = item.label.replace(re, function(match) {
        return "<span style='color:#444444;font-weight:normal;'>" + match + "</span>";
      });
    } else {
      // If it's an SaytSuggestion, only highlight the beginning of the term
      var re = new RegExp("^" + this.term, "i");
      term = item.label.replace(re, "<span style='color:#444444;font-weight:normal;'>" + this.term + "</span>");
    }
    return jQuery("<li></li>")
      .data("item.autocomplete", item)
      .append("<a>" + term + "</a>")
      .appendTo(ul);
  };

  // The server returns typeahead data in a jQuery autocomplete-compatible
  // array of ojbects. See http://jqueryui.com/demos/autocomplete/#overview
  // These objects, however, also contain a "section," which we render below.
  jQuery.ui.autocomplete.prototype._renderMenu = function(ul, items) {
    var autocomplete = this, section;
    jQuery.each(items, function(index, item) {
      if (item.section && item.section != section) {
        section = item.section;
        // Don't display anything for the 'default' section!
        if (section != 'default') ul.append('<li class="ui-menu-item-separator"><span>' + section + '</span></li>');
      }
      autocomplete._renderItem(ul, item);
    });
  };

  jQuery.ui.menu.prototype.refresh = function() {
    var self = this;
    self.isMouseActive = false;

    var items = this.element.children("li:not(.ui-menu-item):has(a)")
        .addClass("ui-menu-item")
        .attr("role", "menuitem");

    items.children("a")
        .addClass("ui-corner-all")
        .attr("tabindex", -1)
        .mousemove(function(event) {
          if (!self.isMouseActive) {
            self.activate(event, $(this).parent());
            self.isMouseActive = true;
          }
        })
        .mouseleave(function() {
          if (self.isMouseActive) {
            self.deactivate();
            self.isMouseActive = false;
          }
    });
  };
}

jQuery(document).ready(function() {
  monkeyPatchAutocomplete();
  var isMobile = (jQuery('.mobile-web').length > 0);
  var isProgram = (jQuery('.program').length > 0);
  var isSearchForm = (jQuery('#search_form').length > 0);
  var isAffiliate = (jQuery('#affiliate').length > 0);
  var isSearchUsaLandingPage = (jQuery('.homepage #landing_page_logo').length > 0);
  var isAffiliateDesktop = isAffiliate && !isMobile;
  var isSearchUsaDesktop = isSearchUsaLandingPage && isSearchForm && !isMobile && !isProgram;

  var position = { my: "left top", at: "left bottom", collision: "none" };
  if (isSearchUsaDesktop) {
    position.at = "left top";
    position.of = "#search_form";
    position.offset = "15 43";
  }

  jQuery(".usagov-search-autocomplete").autocomplete({
    source: function(request, response) {
      jQuery.ajax({
        url: usagov_sayt_url + "q=" + encodeURIComponent(request.term),
        dataType: "jsonp",
        success: response // The data comes back from the server in object form at this time
      });
    },
    minLength: 2,
    delay: 250,
    select: function(event, ui) {
      if (ui.item.data) {
        window.location = ui.item.data;
      } else {
        jQuery(".usagov-search-autocomplete").val(ui.item.value.toString());
        jQuery("#sc").val("1");
        jQuery(this).closest('form').submit();
      }
    },
    open: function() {
      jQuery('.ui-autocomplete').removeClass('ui-corner-all').addClass('ui-corner-bottom');
      jQuery('.one-serp #search_query').addClass('has-sayt-suggestion');
      if (isSearchUsaDesktop) {
        jQuery('.ui-autocomplete').addClass('search_usa_autocomplete');
        jQuery('.ui-autocomplete').css({ width: '621px' });
      } else if (isAffiliateDesktop) {
        jQuery('.ui-autocomplete').addClass('affiliate_autocomplete');
        var inputWidth = jQuery('#search_query').outerWidth(false);
        jQuery('.ui-autocomplete').css('width', (inputWidth - 1) + 'px');
      } else if (isMobile) {
        jQuery('.ui-autocomplete').addClass('mobile_autocomplete');
      } else if (isProgram) {
        jQuery('.ui-autocomplete').addClass('program_autocomplete');
      }
    },
    close: function() {
      jQuery('.one-serp #search_query').removeClass('has-sayt-suggestion');
    },
    position: position
  });

  jQuery(".homepage #search_query").focus();
  jQuery(".page-not-found #search_query").focus();
});

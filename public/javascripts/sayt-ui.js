if (usagov_sayt_url === undefined) {
  var usagov_sayt_url = "http://search.usa.gov/sayt?";
}

function monkeyPatchAutocomplete() {
  var oldFn = jQuery.ui.autocomplete.prototype._renderItem;

  jQuery.ui.autocomplete.prototype._renderItem = function(ul, item) {
    var re = new RegExp("^" + this.term);
    var t = item.label.replace(re, "<span style='color:#444444;font-weight:normal;'>" + this.term + "</span>");
    return jQuery("<li></li>")
      .data("item.autocomplete", item)
      .append("<a>" + t + "</a>")
      .appendTo(ul);
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
          }
          self.isMouseActive = true;
        })
        .mouseleave(function() {
          if (self.isMouseActive) {
            self.deactivate();
          }
          self.isMouseActive = false;
    });
  };
}

jQuery(document).ready(function() {
  monkeyPatchAutocomplete();
  var isMobile = (jQuery('.mobile-web').length > 0);
  var isProgram = (jQuery('.program').length > 0);
  var isSearchForm = (jQuery('#search_form').length > 0);
  var isAffiliate = (jQuery('#affiliate').length > 0);
  var isAffiliateDesktop = isAffiliate && !isMobile;
  var isSearchUsaDesktop = isSearchForm && !isAffiliate && !isMobile && !isProgram;

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
        success: function(data) {
          response(jQuery.map(data, function(item) {
            return {
              label: item,
              value: item
            }
          }));
        }
      });
    },
    minLength: 2,
    delay: 250,
    select: function(event, ui) {
      jQuery(".usagov-search-autocomplete").val(ui.item.value.toString());
      jQuery("#sc").val("1");
      jQuery(this).closest('form').submit();
    },
    open: function() {
      jQuery('.ui-autocomplete').removeClass('ui-corner-all').addClass('ui-corner-bottom');
      if (isSearchUsaDesktop) {
        jQuery('.ui-autocomplete').addClass('search_usa_autocomplete');
        jQuery('.ui-autocomplete').css({ width: '617px' });
      } else if (isAffiliateDesktop) {
        jQuery('.ui-autocomplete').addClass('affiliate_autocomplete');
      } else if (isMobile) {
        jQuery('.ui-autocomplete').addClass('mobile_autocomplete');
      } else if (isProgram) {
        jQuery('.ui-autocomplete').addClass('program_autocomplete');
      }
    },
    position: position
  });

  jQuery("#search_query").focus();
});
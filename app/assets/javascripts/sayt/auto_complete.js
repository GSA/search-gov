var monkeyPatchAutocomplete = function(jQuery) {
  jQuery.ui.autocomplete.prototype._renderItem = function(ul, item) {
    var re = new RegExp("^" + this.term, "i");
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
            self.activate(event, jQuery(this).parent());
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

if (usasearch.config.host && usasearch.config.siteHandle) {
  var saytUrl = usasearch.config.host + "/sayt?name=" +
      usasearch.config.siteHandle + "&";
} else if (typeof usagov_sayt_url != 'undefined') {
  var saytUrl = usagov_sayt_url;
}

if (usasearch.config.autoSubmitOnSelect === undefined) {
  usasearch.config.autoSubmitOnSelect = true;
}

usasearch.jquery = jQuery.noConflict(true);

usasearch.jquery(document).ready(function() {
  var jQuery = usasearch.jquery;
  monkeyPatchAutocomplete(jQuery);

  var usasearchSayt = document.createElement('div');
  usasearchSayt.id = 'usasearch_sayt';
  jQuery('body').append(usasearchSayt);

  usasearchSaytStyle = {
    background:'none',
    border:0,
    display:'block',
    'float':'none',
    height:0,
    lineHeight:0,
    margin:0,
    padding:0,
    position:'static',
    width:0
  };
  jQuery('#usasearch_sayt').css(usasearchSaytStyle);

  jQuery(".usagov-search-autocomplete").autocomplete({
    appendTo: '#usasearch_sayt',
    source: function(request, response) {
      jQuery.ajax({
        url: saytUrl + "q=" + encodeURIComponent(request.term),
        dataType: "jsonp",
        success: response
      });
    },
    minLength: 2,
    delay: 250,
    select: function(event, ui) {
      jQuery(".usagov-search-autocomplete").val(ui.item.value.toString());
      if (usasearch.config.autoSubmitOnSelect) {
        jQuery(this).closest('form').submit();
      }
    },
    open: function() {
      jQuery('#usasearch_sayt .ui-autocomplete').removeClass('ui-corner-all').addClass('ui-corner-bottom');
      jQuery('#usasearch_sayt .ui-autocomplete').css('z-index', 999999);

      var inputWidth = jQuery('.usagov-search-autocomplete').outerWidth(false);
      var resultsWidth = jQuery('#usasearch_sayt .ui-autocomplete').outerWidth(false);
      var delta = inputWidth - resultsWidth;
      var currentWidth = jQuery('#usasearch_sayt .ui-autocomplete').width();
      jQuery('#usasearch_sayt .ui-autocomplete').css('width', currentWidth + delta + 'px');
    }
  });
});

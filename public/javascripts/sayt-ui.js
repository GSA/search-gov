if (usagov_sayt_url === undefined) {
    var usagov_sayt_url = "http://search.usa.gov/sayt?";
}

function monkeyPatchAutocomplete() {
     var oldFn = jQuery.ui.autocomplete.prototype._renderItem;

     jQuery.ui.autocomplete.prototype._renderItem = function( ul, item) {
         var re = new RegExp("^" + this.term) ;
         var t = item.label.replace(re,"<span style='color:#444444;font-weight:normal;'>" + this.term + "</span>");
         return jQuery( "<li></li>" )
             .data( "item.autocomplete", item )
             .append( "<a>" + t + "</a>" )
             .appendTo( ul );
     };
 }

jQuery(document).ready(function()  {
  monkeyPatchAutocomplete();
    var isMobile = (jQuery('#m').val() == 'true');
    var isDesktop = !isMobile;
    var isSearchForm = (jQuery('#search_form').length > 0);
    var isAffiliate = (jQuery('#affiliate').length > 0);
    var isAffiliateDesktop = isAffiliate && isDesktop;
    var isSearchUsaDesktop = isSearchForm && !isAffiliate && isDesktop;

    var position = { my: "left top", at: "left bottom", collision: "none" };
    if (isSearchUsaDesktop) {
        position.of = "#search_form";
        position.offset = "15 0";
    }
  jQuery(".usagov-search-autocomplete").autocomplete({
  	source: function( request, response ) {
  		jQuery.ajax({
  			url: usagov_sayt_url + "q=" + request.term,
  			dataType: "jsonp",
  			data: {
  				featureClass: "P",
  				style: "full",
  				maxRows: 12,
  				name_startsWith: request.term
  			},
  			success: function( data ) {
  				response( jQuery.map(data, function( item ) {
  				  return {
        			label: item,
  						value: item
  					} 
  				}));
  			}
  		});
  	},
  	minLength: 2,
  	delay: 50,
  	select: function( event, ui ) {
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
          }
  		jQuery.ui.keyCode;
  	},
    position: position
  });
});
if (usagov_sayt_url === undefined) {
    var usagov_sayt_url = "http://search.usa.gov/sayt";
}

$(document).ready(function() {
  $(".usagov-search-autocomplete").autocomplete({
  	source: function( request, response ) {
  		$.ajax({
  			url: usagov_sayt_url + "?q=" + request.term,
  			dataType: "jsonp",
  			data: {
  				featureClass: "P",
  				style: "full",
  				maxRows: 12,
  				name_startsWith: request.term
  			},
  			success: function( data ) {
  				response( $.map(data, function( item ) {
  				  return {
        			label: item,
  						value: item
  					}
  				}));
  			}
  		});
  	},
  	minLength: 1,
  	select: function( event, ui ) {
  	  event.preventDefault();
  	  $(".usagov-search-autocomplete").val(ui.item.value.toString());
  		$(this).closest('form').submit();      
  	},
  	open: function() {
  		$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
  	},
  	close: function() {
  		$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
  	}
  }); 
});

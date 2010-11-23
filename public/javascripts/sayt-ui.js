if (usagov_sayt_url === undefined) {
    var usagov_sayt_url = "http://search.usa.gov/sayt?";
}

function __highlight(s, t) {
  var matcher = new RegExp("("+$.ui.autocomplete.escapeRegex(t)+")", "ig" );
  return s.replace(matcher, "<span style='color:#444444;font-weight:normal;'>$1</span>");
}

$(document).ready(function() {
  $(".usagov-search-autocomplete").autocomplete({
  	source: function( request, response ) {
  		$.ajax({
  			url: usagov_sayt_url + "q=" + request.term,
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
        			label: __highlight(item, request.term),
  						value: item
  					}
  				}));
  			}
  		});
  	},
  	minLength: 2,
  	delay: 50,
  	select: function( event, ui ) {
  	  $(".usagov-search-autocomplete").val(ui.item.value.toString());
      $("#sc").val("1");
  		$(this).closest('form').submit();
  	},
  	open: function() {
  		$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
  		$.ui.keyCode;
  	},
  	close: function() {
  		$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
  	}
  }).data( "autocomplete" )._renderItem = function( ul, item ) {
      return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append( $( "<a></a>" ).html(item.label) )
        .appendTo( ul );
    };
});
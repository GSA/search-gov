jQuery(function() {

    jQuery('ul.nav-global li').hover(function(){
    	  jQuery('div:first',this).addClass('wrap-nav-content-hover');
        jQuery(this).addClass("hover");
        jQuery('div:nth-child(2)',this).css('visibility', 'visible');
    
    }, function(){
    
        jQuery(this).removeClass("hover");
		jQuery('div:first',this).removeClass('wrap-nav-content-hover');
        jQuery('div:nth-child(2)',this).css('visibility', 'hidden');
    
    });
    
    jQuery("ul.nav-global li ul li:has(ul)").find("a:first").append(" &raquo; ");

});

//jQuery.noConflict();

jQuery(document).ready(function() {
  jQuery("#topmovers-tooltip").qtip({
    content: {
       text: 'The Top Movers section highlights user queries whose traffic volumes for the day have jumped significantly. In calculating the Top Movers, we look for queries whose search volume is more than 4 standard deviations higher than the historical average search volume for that term. We then take that list and sort them by their actual query volume. This calculation takes into account queries across all search.usa.gov affiliates and traffic sources, including mobile, usa.gov, and both Spanish and English locales.',
       title: {
          text: "What's this:  Top Movers",
          button: 'X'
          }
       }, 
       position: {
         corner: {
            target: 'topLeft',
            tooltip: 'topLeft'
          }
       },
       hide: 'mousedown',    
       style: { 
          width: 350,
          name: 'light'
          },
    show: 'click'
  });
});
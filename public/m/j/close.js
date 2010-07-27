
$(document).ready(function() {
  $('#search_query').keydown(function(){
    if( $("input#search_query").val().length > 0 ) {
      $('.dvSearchClose img').show();
    }
    else
    {
      $('.dvSearchClose img').hide();
    }
  });
  $('.dvSearchClose img').click(function(){
    $("input#search_query").val('');
    $('.dvSearchClose img').hide();
  });
});
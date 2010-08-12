$(document).ready(function() {
  $('#search_query').load(function(){
    if( $("input#search_query").val().length > 0 ) {
      $('.dvSearchClose img').show();
    }
  });
  $('#search_query').keydown(function(){
    if( $("input#search_query").val().length > 0 ) {
      $('.dvSearchClose img').show();
    }
  });
  $('#search_query').one('focus', function() {
      if($("#search_box").get(0)){
           location.href = '#search_box';
      }
  });
  $('.dvSearchClose img').click(function(){
    $("input#search_query").val('');
    $('.dvSearchClose img').hide();
  });
});
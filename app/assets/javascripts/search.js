$(document).ready(function() {
  
  // input text
  $('#s, .cc-input').click(function() {
    if (this.value == this.defaultValue) {
      this.value = '';
    }
  });

  $('#s, .cc-input').blur(function() {
    if (this.value == '') {
      this.value = this.defaultValue;
    }
  });

  // drop down
  $('.search-legend span').click(function() {
    $('.search-legend ul').show();
  });

  $(document).bind('click', function(e) {
    var $clicked = $(e.target);
    if (! $clicked.parents().hasClass('search-legend'))
      $(".search-legend ul").hide();
  });

  $('.search-legend ul li').click(function() {
    // update selected, hide the rest
    var text = $(this).html();
    $('.search-legend span').html(text);
    $('.search-legend ul').hide();

    // update form
    $('#searchform')[0].setAttribute('action', $(this).attr('url'));
    $('#s')[0].setAttribute('name', $(this).attr('name'));
    $('#q')[0].value = $(this).attr('q');
  });
  
  

  
});

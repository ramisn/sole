$(document).ready(function(){

    //$('#checkout_form_address').validate();

    var get_states = function(region){
      var country        = $('p#' + region + 'country' + ' span#' + region + 'country :only-child').val();
      return state_mapper[country];
    }
    
    var update_state = function(region) {
      var states         = get_states(region);

      var state_select = $('span#' + region + 'state select');
      var state_input = $('span#' + region + 'state input');

      if(states) {
        var selected = state_select.val();
        state_select.html('');
        var states_with_blank = [["",""]].concat(states);
        $.each(states_with_blank, function(pos,id_nm) {
          var opt = $(document.createElement('option'))
                    .attr('value', id_nm[0])
                    .html(id_nm[1]);
          if(selected==id_nm[0]){
            opt.attr('selected', 'selected');
          }
          state_select.append(opt);
        });
        state_select.removeAttr('disabled').show();
        state_input.hide().attr('disabled', 'disabled');

      } else {
        state_input.removeAttr('disabled').show();
        state_select.hide().attr('disabled', 'disabled');
      }

    };


  
  $('form.edit_checkout').submit(function() {
    $(this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass('disabled');
  });
  
  
  $('#billing_same_as_shipping').bind('change', function(e) {
    if($(this).is(':checked')) {
      $('#billing table').hide();
    } else {
      $('#billing table').show();
    }
  });
  
  
  $('#signup-toggle').bind('click', function(e) {
    e.preventDefault();
    $('#checkout-signup').toggle();
  });
  
  $('#cc-number input[maxlength]').keyup( function(e) {
    numerical = e.which >= 48 && e.which <= 57
    if ( numerical && $(this).val().length == 4 ) {
      $(this).next().focus();
    }
  });
});






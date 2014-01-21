var add_image_handlers = function() {
  $("#main-image").data('selectedThumb', $('#main-image img').attr('src'));
  $('ul.thumbnails li').eq(0).addClass('selected');
  $('#product-thumbnails li').bind({
    click : function(e) {
      e.preventDefault();
      var href = $(this).find('a').attr('href');
       
      $('#main-image img').attr({
          'src'       : href.replace('mini', 'product')
        , 'longdesc'  : href.replace('mini', 'original')
      });
      
      $('.fullsize-wrapper img').attr('src', href.replace('mini', 'original'));
      
      $("#main-image").data('selectedThumb', $(this).find('a').attr('href'));
      $(this).siblings().removeClass('selected');
      $(this).addClass('selected');
    }
  });
  
  $('a.enlarge').bind('click', function(e) {
    e.preventDefault();
    $('.fullsize-icon').trigger('click');
  });

};

$(document).ready(function(e) {
  
  add_image_handlers();
  
  // Updates available quantities upon size selection
  $('#product-sizes a').bind('click', function(e) {
    
    e.preventDefault();
    var quantity = Number($(this).attr('data-quantity'));
    
    $('#product-quantity select').empty();
    for(var i=1; i<= quantity; i++) {
      var $option = $('<option value="'+ i +'">' + i + '</option>');
      $('#product-quantity select').append($option);
    }
    
    $(this).siblings().removeClass('ui-active');
    $(this).addClass('ui-active');
    
    $('#order_product_id').val($(this).attr('data-product-id'));
    
  });

  // $('#product-sizes a:first').trigger('click');
  
    
  $("form.add-to-cart-form").live("submit", function(event) {
    event.preventDefault();
    var $form = $(event.target);
    var val = $form.find("[name='quantity']").val();
    if (val && val*1 <= 0) {
      alert("Please select quantity");
    } else {
      showAddingSpinner();
      $.ajax({
        url: $form.attr("action"),
        type: $form.attr("method"),
        data: $form.serialize(),
        success: function(data) {
          $(document).trigger("cart:update", {html: data, count: val*1});
          hideAddingSpinner();
        },
        error: function() {
          alert("Failed to add selected product to cart, please try again later");
          hideAddingSpinner();
        }
      });
    }
  });
  
  // Updates form upon quantity selection  
  $('#product-quantity select').bind('change', function(e) {
    $('#order_product_quantity').val($(this).val());
  });
  $('#product-quantity select').change();
})
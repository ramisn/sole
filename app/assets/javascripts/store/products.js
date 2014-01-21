function showAddingSpinner() {
  $(".saving-spinner").fadeIn();
}

function hideAddingSpinner() {
  $(".saving-spinner").fadeOut();
}

$(document).bind("cart:update", function(event, data) {
  var count = $("#header-nav-main #tab-cart #tab-cart-count").html()*1;
  if (isNaN(count)) {
    count = 0;
  }
  count += data.count;
  $("#header-nav-main #tab-cart #tab-cart-count").html(count);
  $("#header-nav-main #tab-cart .left-right-container").html(data.html);
  $("#header-nav-main #tab-cart .left-right-container").css({display: "block", visibility: "visible"});
  $("#header-nav-main #tab-cart").addClass("opening");
});

$(document).bind("cart:finish-add-product-to-cart", function(event, data) {
  data.target.removeClass("submitting");
  if (data.container.find(".select-variant").length > 0) {
    data.target.removeAttr("data-variant_id");
    data.container.find(".select-variant").removeClass("selected");
  }
});

$(function()
{
  /* only merchants will receive this message */
  var isMerchant = false;
  var parentUrl = decodeURIComponent( document.location.href.replace( /^.*[?&]parent=/,'' ) );
  /*
  $.receiveMessage(function(e) {
    var merchantData = deParam(e.data);
    if (merchantData["display_name"])
    {
      $("#display_name").text(merchantData["display_name"].replace(/\+/g," "));
    }
    if (merchantData["banner_url"])
    {
      $("#banner_url").attr('src', merchantData["banner_url"]);
    }
    isMerchant = true;
    $('.merchant').show();
    $('.notmerchant').hide();
  });
  */
  
  //$.postMessage("send iframe size here", parentUrl, parent);

  if (isMerchant) {
    $('#fixCategoryUrls a').each(function(i) {
      $(this).attr('href', $(this).attr('href') + "?parent=" + encodeURIComponent(parentUrl));
    });
  }
  $("#main-container").on("click", ".add-product-to-cart", function(event) {
    event.preventDefault();
    if ($(event.target).hasClass("submitting")) {
      return;
    }
    
    var $container = $(event.target).parents(".product-item");
    var product_id;
    var data;
    var addToCartSuccessCallback = function(data) {
      $(document).trigger("cart:update", {html: data, count: 1});
      $(document).trigger("cart:finish-add-product-to-cart", {target: $(event.target), container: $container});
      hideAddingSpinner();
    };
    var addToCartErrorCallback = function() {
      alert("Failed to add selected product to cart, please try again later");
      $(document).trigger("cart:finish-add-product-to-cart", {target: $(event.target), container: $container});
      hideAddingSpinner();
    };
    
    if ($container.find(".select-variant").length > 0) {
      var variant_id = $(event.target).attr("data-variant_id");
      if (variant_id) {
        product_id = $(event.target).attr("data-product_id");
        
        if (product_id) {
          data = {};
          data.products = {};
          data.products[product_id] = variant_id;
          data.quantity = 1;
          $(event.target).addClass("submitting");
          showAddingSpinner();
          $.ajax({
            type: "post",
            url: "/orders/populate",
            data: data,
            success: addToCartSuccessCallback,
            error: addToCartErrorCallback
          });
        }
      } else {
        alert("Please select a size first");
      }
    } else {
      variant_id = $(event.target).attr("data-variant_id");
      if (variant_id) {
        data = {};
        data.variants = {};
        data.variants[variant_id] = 1;
        $(event.target).addClass("submitting");
        showAddingSpinner();
        $.ajax({
          type: "post",
          url: "/orders/populate",
          data: data,
          success: addToCartSuccessCallback,
          error: addToCartErrorCallback
        });
      } else {
        alert("We are very sorry, but there are no items available in store");
      }
    }
  });
  $("#main-container").on("click", ".select-variant", function(event) {
    event.preventDefault();
    var $container = $(event.target).parents(".product-item");
    var variant_id = $(event.target).attr("data-variant_id");
    
    $container.find(".select-variant").removeClass("selected");
    if (variant_id) {
      $container.find(".add-product-to-cart").attr("data-variant_id", variant_id);
      $(event.target).addClass("selected")
    }
  });
  $("#tab-cart").hover(null, function(event) {
    $(this).removeClass("opening");
  });
});

function deParam(s) {

  var obj = {};
  try {
    var ss = new String(s);
    var pairs = ss.split('&');
    for (var i=0; i <pairs.length; i++) {
      var pair = pairs[i].split('=');
      obj[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
    }
    return obj;
  }
  catch (e) {
    alert("deParam: exception " + e);
    return obj;
  }
}

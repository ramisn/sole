var addthis_config  = { ui_click: true };

/* Dynamic Flash Messages */

function emptyFlashMessages() {
  $('#flash_messages').empty();
}
function addFlashMessage(type, message) {
  $('#flash_messages').append('<div class="flash '+type+'">'+message+'</div>');
}

$(document).ready(function() {

		// Tabs
		$('#tabs').tabs();

		// Dialog			
		$('#dialog').dialog({
			autoOpen: false,
			width: 600,
			buttons: {
				"Ok": function() { 
					$(this).dialog("close"); 
				}, 
				"Cancel": function() { 
					$(this).dialog("close"); 
				} 
			}
		});
		
		// Dialog Link
		$('#dialog_link').click(function(){
			$('#dialog').dialog('open');
			return false;
		});

		// Datepicker
		$('#datepicker').datepicker({
			  inline  : true
		});
		
		// Progressbar
		$("#progressbar").progressbar({
			  value   : 20 
		});
		
		//hover states on the static widgets
		$('#dialog_link, ul#icons li').hover(
			function() { $(this).addClass('ui-state-hover'); }, 
			function() { $(this).removeClass('ui-state-hover'); }
		);

    $('.product-item a.favorite, a.simpleButton.favorite, a.favoritable').live('click', function(e) {
      
      e.preventDefault();
      
      $.ajax({
          url       : $(this).attr('href')
        , dataType  : 'json'
        , success   : function(data) { 
          
            emptyFlashMessages();
            for (var type in data.flash) {
              addFlashMessage(type, data.flash[type]);
            } 

          }
        , error     : function(data) {
            emptyFlashMessages();
            for (var type in data.flash) {
              addFlashMessage(type, data[type]);
            }
          }
        , type : 'POST'
      });
      
      // Switch between Fav and Unfav
      if($(this).hasClass('fav')) {
        $(this).removeClass('fav').addClass('unfav').attr('title', 'Remove from Favorites').html('Remove from Favs');
        $(this).attr('href', $(this).attr('data-unfav-url'));
      } else {
        $(this).removeClass('unfav').addClass('fav').attr('title', 'Add to Favorites').html('Add to Favorites');
        $(this).attr('href', $(this).attr('data-fav-url'));
      }

    }); 
    
    $("img").fullsize();
    
  // $('#settings-dropdown').shadow();
  
  // Remove an item from the cart by setting its quantity to zero and posting the update form
  $('form#updatecart a.delete').show().live('click', function(e){
    $(this).parents('tr').find('input.line_item_quantity').val(0);
    $(this).parents('form').submit();
    e.preventDefault();
  });

  $('#per-page-' + $('#collection').attr('data-per')).addClass('ui-active');
  $('#breadcrumbs li:last').addClass('last');
 
  // ******************
  // Header Tabs
  // ******************
  
  $("#header-nav-sub > ul").superfish({
          animation: {opacity:'show'},
          delay: 600,
          speed: 'slow',
          autoArrows: false,
          dropShadows: false,
          disableHI: false
  });
  
  $("#header-nav-main > ul").superfish({
          animation: {opacity:'show'},
          delay: 0,
          speed: 'fast',
          autoArrows: false,
          dropShadows: false,
          disableHI: true
  });

  $('#header-nav-sub > ul > li, #header-nav-main > ul > li').each(function(i) {
    
    if( ( $(this).offset().left ) > $(window).width()/2 ) {
      $(this).find('.left-right-container').addClass('anchored-right');
    }
  });
  
  $('#tab-account').bind('mouseover', function(e) {
    $(this).find('.drop-down').stop(true, true).fadeIn();
  });
  
  
  $('#tab-account').bind('mouseout', function(e) {
    $(this).find('.drop-down').stop(true, true).delay(1000).fadeOut();
  });
  
  // This line fixes a display bug in FF for the accessory tab.
  $('#sub-tab-accessories .left-right-container').addClass('anchored-right');

  // 
 
  
  // ******************
  // Sign in / Sign out
  // ******************
  
  $('a#login-link').bind('click', function(e) {
    e.preventDefault();
    $('#signin-screen').css({'visibility':'visible'}).height($(window).height());
  });
  
  $('a#signup-link').bind('click', function(e) {
    e.preventDefault();
    
    $('#signup-screen').css({'visibility':'visible'}).height($(document).height());
  });
  
  $('.modal-screen .close').bind('click', function(e) {
    e.preventDefault();
    $('.modal-screen').css({
      'visibility' : 'hidden'
    })
  });
  
  $('#signin-screen-signup-link').bind('click', function(e) {
    e.preventDefault();
    $('#signin-screen').css({'visibility':'hidden'});
    $('#signup-screen').css({'visibility':'visible'}).height($(document).height());
  });
  
  // ******************
  // Search Field
  // ******************
  
  // Add placeholder support
  // Commenting this out as it doesn't play well with IE
  // if (!Modernizr.input.placeholder && !$.support.placeholder) {
  //     var active = document.activeElement;
  //     $(':text').focus(function () {
  //        if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
  //           $(this).val('').removeClass('hasPlaceholder');
  //        }
  //     }).blur(function () {
  //        if ($(this).attr('placeholder') != '' && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
  //           $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
  //        }
  //     });
  //     $(':text').blur();
  //     $(active).focus();
  //     $('form:eq(0)').submit(function () {
  //        $(':text.hasPlaceholder').val('');
  //     });
  //   }
  
  $('#search-terms').bind('keyup', function(e) {
   
    if($(this).val().length > 0) {
      $('#search-legend').show();
    } else {
      $('#search-form').removeClass('valid');
      $('#search-legend').hide();
    }
    
    if($('#search-legend').is(':visible')) {
      var code = e.keyCode || e.which;
      
      if(code == 40) {
        
        e.preventDefault();
        // DOWN
        row = $('#search-legend dd.hover').next();
        if(row.length == 0)  { row = $('#search-legend dd:first')};
     
        $('#search-legend dd.hover').removeClass('hover');
        row.addClass('hover');
      } else if (code == 38) {
        // UP
        e.preventDefault();
        row = $('#search-legend dd.hover').prev();
     
        $('#search-legend dd.hover').removeClass('hover');
        row.addClass('hover');
      } else if (code == 13) {
        e.preventDefault();
        e.stopPropagation();
        row = $('#search-legend dd.hover')
        if(row.length == 0)  { row = $('#search-legend dd:first')};

        row.trigger('click');
      } 
    }
  });
  
  $('#search-terms').bind('keydown', function(e) {
    
  });
  
  $('#search-terms').bind('focus', function(e) {
    $('#search-form label').hide();
  });

  $('#search-legend dd').bind('click', function(e) {
    $('#search-type').val($(this).attr('type'));
    $('#search-form').attr('action', $(this).attr('url'));
    $('#search-form').submit();
  });
  

  // ******************
  // Section Product Scroller
  // ******************
  $.each($('.section-product-scroller'), function(i) {
    
    if($(this).attr('data-page-current') == 1) {
      $(this).addClass('page-first');
    }
    
    if($(this).attr('data-page-current') == $(this).attr('data-page-last')) {
      $(this).addClass('page-last');
    }
    
  });
  
  $('.section-product-scroller-arrow').live('click', function(e) {
    e.preventDefault();
    var scroller  = $(this).parents('.section-product-scroller')
      , page      = Number(scroller.attr('data-page-current'))
      , lastpage  = Number(scroller.attr('data-page-last'));
    
    if($(this).hasClass('prev')) {
      page -= 1;
    } else {
      page += 1;
    }
    
    scroller.attr('data-page-current', page);
    scroller.removeClass('page-first page-last');
    
    if (page == lastpage) {
      scroller.addClass('page-last');
    } 
    
    if (page == 1){
      scroller.addClass('page-first');
    }
    
    $.ajax({
        url       : scroller.attr('data-url')
      , method    : 'GET'
      , dataType  : 'html'
      , success   : function(data) {
        // #TODO : Replace accordingly 
        scroller.replaceWith($(data));
      }
    })
    
  });
  
  
  // Facebook Popup
  var popup_window;
  function login(provider_url, title, width, height) {
    var screenX = typeof window.screenX != 'undefined' ? window.screenX : window.screenLeft,
    screenY     = typeof window.screenY != 'undefined' ? window.screenY : window.screenTop,
    outerWidth  = typeof window.outerWidth != 'undefined' ? window.outerWidth : document.body.clientWidth,
    outerHeight = typeof window.outerHeight != 'undefined' ? window.outerHeight : (document.body.clientHeight - 22),
    left        = parseInt(screenX + ((outerWidth - width) / 2), 10),
    top         = parseInt(screenY + ((outerHeight - height) / 2.5), 10),
    features    = ('width=' + width + ',height=' + height + ',left=' + left + ',top=' + top);
      
    popup_window = window.open(provider_url, title, features);
      
    if (window.focus)
      login_window.focus();
      
    return false;
  }
  
  $('.signup-social-button').click(function(e) {
    e.preventDefault()
    login($(this).attr('href'), $(this).attr('title'), 400, 400);
  });
  
  $("[rel='tooltip']").tooltip();
});
jQuery.fn.shadow = function() {
  
  return this.each(function() {
    
		var h     = $(this).outerHeight()
		  , w     = $(this).outerWidth()
      , stl   = $('<div class="shadowtl"></div>')
      , st    = $('<div class="shadowtop"></div>')
      , str   = $('<div class="shadowtr"></div>')
      , sl    = $('<div class="shadowleft"></div>')
      , sr    = $('<div class="shadowright"></div>')
      , sbl   = $('<div class="shadowbl"></div>')
      , sb    = $('<div class="shadowbottom"></div>')
      , sbr   = $('<div class="shadowbr"></div>')
      ;
      		  
		$(this).addClass('shadowed');
    
    
		$(this).append(stl, st, str, sl, sr, sbl, sb, sbr);
		
		$(sl).height(h -40);
		$(sr).height(h -40);
		$(st).width(w - 40);
		$(sl).width(10);
		$(sr).width(10);
		$(sb).width(w - 40);
		
  });
  
}

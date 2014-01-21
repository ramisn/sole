// Filter Engine. Custom Class to handle all of Soletron's filtering options
// Gregory Mirzayantz 2012
// To set a filter    : setFilter({key:'filter name', value: filter value(s)})
// To remove a filter : removeFilter('filter name')

var FilterEngine = function(options) {
  this.initialize(options);
}

FilterEngine.prototype = {
  defaults : {
      url       : window.location.href
    , el        : '#current-filters'
    , template  : '#template-filter'
    , notrack   : ['sort', 'show_only']
    , searchOptions  : {}
  },
  
  initialize : function(options) {
    var _this = this;
    this.filters = [];
    this.settings = $.extend({}, this.defaults, options);

    $.each($(this.settings.el).find('a'), function(i) {
      
      var filter = {
          key   : $(this).attr('data-key')
        , value : $(this).attr('data-value')
      }
      
      $(this).data('filter', filter);
      _this.filters.push(filter);

    });
    
  },
  
  setFilter : function(data) {
    if(!data) return false;
    if(!data.value) {
      this.removeFilter(data);
      return false;
    }
    
    this.filters.push(data);
    this.render();
  },
  
  removeFilter : function(data) {
    
    this.filters = $.grep(this.filters, function(filter) {    
      if(data.key != filter.key) return true
      if(data.value && data.value != filter.value ) return true
      return false;
    });
    
    this.render();
  },
  
  render : function() {
    var _this = this
      , template = $(this.settings.template).html()
      , el = $(this.settings.el);
    
    el.empty();
    $.each(this.filters, function(i) {
      // Don't render filters in notrack setting
      if($.inArray(this.key , _this.settings.notrack) == -1) {
        filt = $(template);
        filt.html(this.key.capitalize() + ': ' + this.value.toString());
        filt.data('filter', this); 
        el.append($(filt));
      } 

    });
    
    $(this.el).show();
    this.submit();
  },
  
  submit : function() {
    $('#filter-spinner-new').fadeIn();
    
    var data = $.extend({}, this.settings.searchOptions);
    $.each(this.filters, function(i) {
      
      if(data[this.key]) {
        data[this.key] += ',' + this.value;
        
      } else {
        data[this.key] = this.value;
        
      }

    });

    
    $.ajax({
        url     : this.settings.url.split('?')[0]
      , method  : 'GET'
      , data    : data
      , success : function(resp, status) {
        $('#filter-spinner-new').fadeOut();
        
        var $content;
        if ($(resp).attr("id") == "products") {
          $content = $(resp);
        } else {
          $content = $(resp).find('#products');
        }
        
        
        $('#products').replaceWith($content);
        $.each($('#filters ul'), function(i) {
          var html =  $(resp).find('#'+$(this).attr('id')).html();
          $(this).html(html);
          
        });
        
        refreshFilters();
        addthis.toolbox('.addthis_toolbox');
      }
    });
    
  }
}


$(document).ready(function() {
  
  Soletron.filters = new FilterEngine();

  Soletron.filters.selected = null;

  $('#filters ul input').live('change', function(e) {
    
    var filter = {
        key   : $(this).parents('ul').attr('name')
      , value : $(this).val()
    }
    
    if($(this).is(':checked')) {
      Soletron.filters.setFilter(filter);
    } else {
      Soletron.filters.removeFilter(filter);
    }
    
  });

  $('#filters').accordion({
      autoHeight  : false
    , navigation  : true
    , collapsible : true
  });
  
  $('#content-options select').bind('change', function(e) {
    var selected = $(this).find('option:selected').attr('value');
    if(selected == null) return false;
    Soletron.filters.settings.searchOptions[$(this).attr('name')] = selected;
    Soletron.filters.submit();
    
  }); 
  
  $('#current-filters a').live('click', function(e) {
    e.preventDefault();
    var filter = $(this).data('filter');
    checkBox(filter, false);
    Soletron.filters.removeFilter(filter);
  });

  
  refreshFilters();
});



function refreshFilters() {
  // Pre check selected filters
  $.each($('#current-filters a'), function(i) {
    checkBox($(this).data('filter'), true);
  })
}


function checkBox(filter, check) {
  var check = check || true;
  // Case insensitive match
  var checkbox = $('#filter-'+filter.key+'s input:iattr(value,'+filter.value+')');
  if(checkbox.length == 0) {
    checkbox = $('#filter-'+filter.key+'s input[value="'+filter.value+'"]');
  }
  checkbox.attr('checked', check);
}
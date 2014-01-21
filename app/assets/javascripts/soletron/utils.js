String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

// case insensitive selector
$.expr[':'].iattr = function(obj, params, meta, stack) {
    var opts = meta[3].match(/(.*)\s*,\s*(.*)/);
    return (opts[1] in obj) && (obj[opts[1]].toLowerCase().indexOf(opts[2].toLowerCase()) === 0);
};
$(function()
{
  /* only merchants will receive this message */
  var isMerchant = false;
  var parentUrl = decodeURIComponent( document.location.href.replace( /^.*[?&]parent=/,'' ) );
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
  
  $.postMessage("send iframe size here", parentUrl, parent);

  if (isMerchant) {
    $('#fixCategoryUrls a').each(function(i) {
      $(this).attr('href', $(this).attr('href') + "?parent=" + encodeURIComponent(parentUrl));
    });
  }

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
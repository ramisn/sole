#= require ../underscore-min
#= require ../backbone-min
#= require ../jquery.blockUI
class ProductRouter extends Backbone.Router
  routes:
    "!show/:product": "show"


  show: (product) ->
    $('#content-full').block
      message: '<h1>Loading Product Details</h1>'

    $.get "/products/#{product}.html?layout=false", (data) ->
      $('#content-full').unblock()
      $('#product-page-styles').replaceWith(data)
      addthis.toolbox document.getElementById('addthis_toolbox')


$(document).ready ->
  new ProductRouter

  Backbone.history.start()
var add_image_handlers=function(){$("#main-image").data("selectedThumb",$("#main-image img").attr("src")),$("ul.thumbnails li").eq(0).addClass("selected"),$("#product-thumbnails li").bind({click:function(e){e.preventDefault();var t=$(this).find("a").attr("href");$("#main-image img").attr({src:t.replace("mini","product"),longdesc:t.replace("mini","original")}),$(".fullsize-wrapper img").attr("src",t.replace("mini","original")),$("#main-image").data("selectedThumb",$(this).find("a").attr("href")),$(this).siblings().removeClass("selected"),$(this).addClass("selected")}}),$("a.enlarge").bind("click",function(e){e.preventDefault(),$(".fullsize-icon").trigger("click")})};$(document).ready(function(e){add_image_handlers(),$("#product-sizes a").bind("click",function(e){e.preventDefault();var t=Number($(this).attr("data-quantity"));$("#product-quantity select").empty();for(var n=1;n<=t;n++){var r=$('<option value="'+n+'">'+n+"</option>");$("#product-quantity select").append(r)}$(this).siblings().removeClass("ui-active"),$(this).addClass("ui-active"),$("#order_product_id").val($(this).attr("data-product-id"))}),$("#product-sizes a:first").trigger("click"),$("#product-quantities").bind("change",function(e){$("#order_product_quantity").val($(this).val())})});
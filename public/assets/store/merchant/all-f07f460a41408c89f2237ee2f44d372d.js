function Size(e,t){this.size_id=e,this.quantity=t}function SKU(e,t,n,r,i,s){this.primary_color=e,this.secondary_color=t,this.sku=n,this.id=r,this.attribute=i,this.sizes=s}function removeElement(e){e.parent().children().length>2?(status_element=$("input#variant_data_status_"+e.attr("id"),e),status_element!=null&&status_element.html()!=null&&status_element.val()!="<%= STATUS[:new] %>"&&(product_id_element=$("input#variant_data_product_id_"+e.attr("id"),e),product_id_element!=null&&product_id_element.html()!=null&&(status_element.val("<%= STATUS[:delete] %>"),status_element.appendTo(e.parent()),product_id_element.appendTo(e.parent()))),e.remove()):alert("You may not remove the last Size for this SKU. Do you want to remove the entire SKU instead?")}function insertSize(e,t){var n=e==null?$("div#divSKU0"):e,r=$("div#divSize0",n),i=r.clone();r.parent().append(i),i.attr("id","divSizeNew"),row_number=n.attr("row_number");var s=n.attr("count_size_rows");s==null?s=1:s++,n.attr("count_size_rows",s),$("label#idSize",i).attr("for","variant_data_"+row_number+"_per_size_data_"+s+"_Size"),$("select#variant_data_"+row_number+"_per_size_data_0_Size",i).attr("name","variant_data["+row_number+"]per_size_data["+s+"][Size]"),$("select#variant_data_"+row_number+"_per_size_data_0_Size",i).attr("row_number",row_number),t!=null&&$("select#variant_data_"+row_number+"_per_size_data_0_Size",i).val(t.size_id),$("select#variant_data_"+row_number+"_per_size_data_0_Size",i).attr("id","variant_data_"+row_number+"_per_size_data_"+s+"_Size"),$("label#idOnHand",i).attr("for","variant_data_"+row_number+"_per_size_data_"+s+"_on_hand"),$("input#variant_data_"+row_number+"_per_size_data_0_on_hand",i).attr("name","variant_data["+row_number+"]per_size_data["+s+"][on_hand]"),$("input#variant_data_"+row_number+"_per_size_data_0_on_hand",i).attr("row_number",row_number),t!=null&&$("input#variant_data_"+row_number+"_per_size_data_0_on_hand",i).val(t.quantity),$("input#variant_data_"+row_number+"_per_size_data_0_on_hand",i).attr("id","variant_data_"+row_number+"_per_size_data_"+s+"_on_hand"),$("input#variant_data_"+row_number+"_per_size_data_0_skip",i).attr("name","variant_data["+row_number+"]per_size_data["+s+"][skip]"),$("input#variant_data_"+row_number+"_per_size_data_0_skip",i).attr("id","skipNew"),$("input#skipNew",i).attr("value",0),$("input#skipNew",i).attr("id","variant_data_"+row_number+"_per_size_data_"+s+"_skip"),$("a#addSize",n).attr("row_number",row_number),i.attr("row_number",row_number),i.attr("id","divSize"+s),i.show(),$("input#params_count").attr("value",s)}function insertSKU(e,t){var n=$("fieldset.sku-variant:first"),r=$("fieldset.sku-variant").length,i=n.clone(),s="variant_data_"+r;i.attr("id",s),$.each(i.find("input"),function(e){var t=$(this).parent("p").attr("data-property"),n="variant_data_"+r+"_"+t;$(this).attr("name","variant_data["+r+"]["+t+"]"),$(this).attr("id",n),$(this).siblings("label").attr("for",n)}),i.insertBefore($("#product-form-sku-info .options")),i.data("index",r);var o=$("#image-uploads-0").clone();o.attr("id","image-uploads-"+r),$("#product-form-images").append(o)}$(document).ready(function(e){$("#store-permalink a.edit").bind("click",function(e){$("#permalink").show(),$("#store-permalink a.cancel").show(),$("#id_permalink_view").hide(),$(this).hide()}),$("#store-permalink a.cancel").bind("click",function(e){$("#permalink").hide(),$("#store-permalink a.edit").show(),$("#id_permalink_view").show(),$(this).hide()}),$(".datepicker").datepicker({dateFormat:"yy/mm/dd",showOn:"button",buttonImage:"/assets/datepicker/cal.gif",buttonImageOnly:!0}),$("#add-sku").bind("click",function(e){e.preventDefault(),insertSKU()}),$("fieldset.sku-variant .remove").live("click",function(e){e.preventDefault(),$("#image-uploads-"+$(this).parent().attr("data-index")).remove(),$(this).parent().remove()}),$("#product-form-images fieldset .add, #product-form-images fieldset .edit").live("click",function(e){e.preventDefault(),$(this).siblings("input").trigger("click")}),$('#product-form-images fieldset input[type="file"]').live("change",function(e){})});var hasSize=!1;
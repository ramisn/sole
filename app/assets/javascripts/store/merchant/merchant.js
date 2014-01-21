$(document).ready(function(e) {

  $('#store-permalink a.edit').bind('click', function(e) {
    $('#permalink').show();
    $('#store-permalink a.cancel').show();
    $('#id_permalink_view').hide();
    $(this).hide();
  });
  
  $('#store-permalink a.cancel').bind('click', function(e) {
    $('#permalink').hide();
    $('#store-permalink a.edit').show();
    $('#id_permalink_view').show();
    $(this).hide();
  });
  
  $('.datepicker').datepicker({
    dateFormat: 'yy/mm/dd',
    showOn: "button",	
    buttonImage: "/assets/datepicker/cal.gif",
    buttonImageOnly: true	
  });
  
  $('#add-sku').bind('click', function(e) {
    e.preventDefault();
    insertSKU();
  });
  
  $('fieldset.sku-variant .remove').live('click', function(e) {
    e.preventDefault();
    if (!confirm("Are you sure? This can't be undone")) {
      return;
    }
    
    var $this = $(this);
    var index = $this.parents("fieldset.sku-variant").attr('data-index');
    var product_id = $this.parents("fieldset.sku-variant").find(".product-id").val();
    /*
    var variant_ids = [];
    $this.parents("fieldset.sku-variant").find(".variant-id").each(function(index, element) {
      var val = $(element).val();
      if (val) {
        variant_ids.push(val);
      }
    });
    */
   
    /*
     * Image will be deleted with variant, so no need to delete image
    var ids = [];
    $('#image-uploads-' + index).find(".uploaded-image input").each(function(i, element) {
      ids.push($(element).val());
    });
    if (ids.length > 0) {
      $.ajax({
        url: "/merchant/products/delete_images",
        type: "delete",
        data: {image_ids: ids}
      })
    }
    */
   
    if (product_id) {
      $this.parents("fieldset.sku-variant").hide();
      $('#image-uploads-' + index).hide();
      $.ajax({
        url: "/merchant/store/" + store_username + "/products/" + product_id,
        type: "delete",
        success: function() {
          $('#image-uploads-' + index).remove();
          $this.parents("fieldset.sku-variant").remove();
        },
        error: function() {
          $('#image-uploads-' + index).show();
          $this.parents("fieldset.sku-variant").show();
        }
      });
      
      /*
      $.ajax({
        url: "/merchant/products/delete_variants",
        type: "delete",
        data: {variant_ids: variant_ids},
        success: function() {
          $('#image-uploads-' + index).remove();
          $this.parents("fieldset.sku-variant").remove();
        },
        error: function() {
          $('#image-uploads-' + index).show();
          $this.parents("fieldset.sku-variant").show();
        }
      });
      */
    } else {
      $('#image-uploads-' + index).remove();
      $this.parents("fieldset.sku-variant").remove();
    }
  });
  
  $('#product-form-images fieldset .add, #product-form-images fieldset .edit').live('click', function(e) {
    e.preventDefault();
    $(this).siblings('input').trigger('click');
  });
  
  $('#product-form-images fieldset input[type="file"]').live('change', function(e) {
    // #TODO: Send data to upload image inline and update form
  });
  
});



function Size(size_id, quantity)
{
    this.size_id = size_id;
    this.quantity = quantity;
}

function SKU(primary_color_id, secondary_color_id, sku_name, product_id, attr, sizes)
{
    this.primary_color = primary_color_id;
    this.secondary_color = secondary_color_id;
    this.sku = sku_name;
    this.id = product_id;
    this.attribute = attr;
    this.sizes = sizes;
}



function removeElement(element)
{
  if (element.parent().children().length > 2)
  {
    status_element = $("input#variant_data_status_" + element.attr("id"), element);
    if ((status_element != null) && (status_element.html() != null) && (status_element.val() != "<%= STATUS[:new] %>"))
    {
      product_id_element = $("input#variant_data_product_id_" + element.attr("id"), element);
      if ((product_id_element != null) && (product_id_element.html() != null))
      {
        status_element.val("<%= STATUS[:delete] %>");
        status_element.appendTo(element.parent());
        product_id_element.appendTo(element.parent());
      }
    }
    element.remove();
  }
  else
  {
    alert("You may not remove the last Size for this SKU. Do you want to remove the entire SKU instead?")
  }
}

var hasSize = false;

function insertSize(obj, size)
{
  var divParent = (obj == null) ? $('div#divSKU0') : obj;
  var div = $('div#divSize0', divParent);
  var divSizeNew = div.clone();
  div.parent().append(divSizeNew);
  divSizeNew.attr("id", "divSizeNew");

  row_number = divParent.attr("row_number");
  var cSizeRows = divParent.attr("count_size_rows");
  if (cSizeRows == null)
  {
    cSizeRows = 1;
  }
  else
  {
    cSizeRows++;
  }
  divParent.attr("count_size_rows", cSizeRows);

  $("label#idSize", divSizeNew).attr("for", "variant_data_" + row_number + "_per_size_data_" + cSizeRows + "_Size");
  $("select#variant_data_" + row_number + "_per_size_data_0_Size", divSizeNew).attr("name", "variant_data[" + row_number + "]per_size_data[" + cSizeRows + "][Size]");
  $("select#variant_data_" + row_number + "_per_size_data_0_Size", divSizeNew).attr("row_number", row_number);
  if (size != null)
  {
    $("select#variant_data_" + row_number + "_per_size_data_0_Size", divSizeNew).val(size.size_id);
  }
  $("select#variant_data_" + row_number + "_per_size_data_0_Size", divSizeNew).attr("id", "variant_data_" + row_number + "_per_size_data_" + cSizeRows + "_Size");

  $("label#idOnHand", divSizeNew).attr("for", "variant_data_" + row_number + "_per_size_data_" + cSizeRows + "_on_hand");
  $("input#variant_data_" + row_number + "_per_size_data_0_on_hand", divSizeNew).attr("name", "variant_data[" + row_number + "]per_size_data[" + cSizeRows + "][on_hand]");
  $("input#variant_data_" + row_number + "_per_size_data_0_on_hand", divSizeNew).attr("row_number", row_number);
  if (size != null)
  {
    $("input#variant_data_" + row_number + "_per_size_data_0_on_hand", divSizeNew).val(size.quantity);
  }
  $("input#variant_data_" + row_number + "_per_size_data_0_on_hand", divSizeNew).attr("id", "variant_data_" + row_number + "_per_size_data_" + cSizeRows + "_on_hand");

  $("input#variant_data_" + row_number + "_per_size_data_0_skip", divSizeNew).attr("name", "variant_data[" + row_number + "]per_size_data[" + cSizeRows + "][skip]");
  $("input#variant_data_" + row_number + "_per_size_data_0_skip", divSizeNew).attr("id", "skipNew");
  $("input#skipNew", divSizeNew).attr("value", 0);
  $("input#skipNew", divSizeNew).attr("id", "variant_data_" + row_number + "_per_size_data_" + cSizeRows + "_skip");

  $("a#addSize", divParent).attr("row_number", row_number);
  divSizeNew.attr("row_number", row_number);

  divSizeNew.attr("id", "divSize" + cSizeRows);

  divSizeNew.show();

  $('input#params_count').attr("value", cSizeRows);
}

function insertSKU(sku, id_override)
{
  var div   = $('fieldset.sku-variant:first')
    , count = $('fieldset.sku-variant').length
    , $sku  = div.clone()
    , id    = 'variant_data_' + count


  $sku.attr('id', id);
  if ($sku.find(".size-and-quantity").length > 1) {
    $sku.find(".size-and-quantity").each(function(index, element) {
      if (index > 0) {
        $(element).remove();
      }
    });
  }
  $sku.find('input, select').each(function(i) {
    //var prop = $(this).parent('p').attr('data-property');
    //var input_id = "variant_data_" + count + "_" + prop;
    var name = $(this).attr("name");
    name = name.replace(/\d+/, count);
    $(this).attr('name', name);
    $(this).val("");
    var input_id = $(this).attr("id");
    if (input_id) {
      input_id = input_id.replace(/\d+/, count);
      $(this).attr('id', input_id);
      $(this).siblings('label').attr('for', input_id);
    }
  });

  $sku.find(".remove").show();
  $sku.insertBefore($('#product-form-sku-info .options'));
  $sku.attr('data-index', count);
  var $imageRow = $('#image-uploads-0').clone();
  
  $imageRow.attr('id', 'image-uploads-' + count);
  $imageRow.attr('data-index', count);
  $imageRow.removeAttr("variant_id");
  $imageRow.find(".uploaded-image").remove();
  $imageRow.find(".uploading-file").show();
  $imageRow.find(".uploading-icon").hide();
  $imageRow.find(".sku-id").html("");
  $('#product-form-images').append($imageRow);
  $("#image-uploads-" + count).find(".uploading-file").each(function(index, element) {
    createUploadFormFor(element, $(element).parents(".upload-section"));
  });  
}

function createUploadForm($container, element, url, onSubmitHandler, onCompleteHandler) {
  var uploader = new qq.FileUploader({
    // pass the dom node (ex. $(selector)[0] for jQuery users)
    element: element,
    // path to server-side upload script
    action: url,
    uploadButtonText: "Add Image",
    listElement: $container.find(".list-elements")[0],
    onSubmit: onSubmitHandler,
    onComplete: onCompleteHandler
  });
  return uploader;
}

function createUploadFormFor(element, $container) {
  var uploader = createUploadForm($container, element, "/merchant/products/upload_image", function(id, filename) {
    var variant_id = $container.parents(".image-uploads").attr("variant_id");
    var csrf_param = $("[name='csrf-param']").attr("content");
    var csrf_token = $("[name='csrf-token']").attr("content");
    var data = {};
    data[csrf_param] = csrf_token;
    if (variant_id) {
      data.variant_id = variant_id;
    }
    uploader.setParams(data);
    $container.find(".uploading-file").hide();
    $container.find(".uploading-icon").show();
    
    return true;
  }, function(id, fileName, response) {
    $container.find(".uploading-icon").hide();
    if (response.id) {
      var index = $container.parents(".image-uploads").attr("data-index");
      var $html = $(".uploaded-image-template").clone();
      $html.find("img").attr("src", response.product_url);
      $html.find("img").addClass("image_" + response.id);
      $html.find("input").attr("name", "variant_data[" + index + "][images][]");
      $html.find("input").val(response.id);
      $container.find(".uploaded-files").append($html.html());
    } else {
      alert("Error uploading file, please try again later.");
      $container.find(".uploading-file").show();
      $container.find(".uploading-icon").hide();
    }
  });
  if ($container.find(".uploaded-image img").length > 0) {
    $container.find(".uploading-file").hide();
  }
}
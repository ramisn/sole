$(document).ready(function(){var e=function(e){var t=$("p#"+e+"country"+" span#"+e+"country :only-child").val();return state_mapper[t]},t=function(t){var n=e(t),r=$("span#"+t+"state select"),i=$("span#"+t+"state input");if(n){var s=r.val();r.html("");var o=[["",""]].concat(n);$.each(o,function(e,t){var n=$(document.createElement("option")).attr("value",t[0]).html(t[1]);s==t[0]&&n.attr("selected","selected"),r.append(n)}),r.removeAttr("disabled").show(),i.hide().attr("disabled","disabled")}else i.removeAttr("disabled").show(),r.hide().attr("disabled","disabled")};$("form.edit_checkout").submit(function(){$(this).find(":submit, :image").attr("disabled",!0).removeClass("primary").addClass("disabled")}),$("#billing_same_as_shipping").bind("change",function(e){$(this).is(":checked")?$("#billing table").hide():$("#billing table").show()}),$("#signup-toggle").bind("click",function(e){e.preventDefault(),$("#checkout-signup").toggle()}),$("#cc-number input[maxlength]").keyup(function(e){numerical=e.which>=48&&e.which<=57,numerical&&$(this).val().length==4&&$(this).next().focus()})});
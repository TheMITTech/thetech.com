(function(){var e;e=function(){var e;return jQuery.fn.selectText=function(){var e,t,n,e,i;this.find("input").each(function(){0!==$(this).prev().length&&$(this).prev().hasClass("p_copy")||$('<p class="p_copy" style="position: absolute; z-index: -1;"></p>').insertBefore($(this)),$(this).prev().html($(this).val())}),t=document,n=this[0],t.body.createTextRange?(e=document.body.createTextRange(),e.moveToElementText(n),e.select()):window.getSelection&&(i=window.getSelection(),e=document.createRange(),e.selectNodeContents(n),i.removeAllRanges(),i.addRange(e))},e=function(e){var t;return e.append($("<i class='fa fa-circle-o-notch fa-spin'></i>")),t=$("#editable_form"),t.attr("action",e.data("editable-url")),t.children("input[type=hidden]").attr("name",e.data("editable-object")+"["+e.data("editable-field")+"]"),t.children("input[type=hidden]").val(e.text()),$.rails.handleRemote(t)},$(document).on("click","[data-editable-url]",function(){if("true"!==$(this).attr("contenteditable"))return $(this).attr("contenteditable","true"),$(this).data("editable-original",$(this).text()),$(this).selectText()}),$(document).on("focusout","[data-editable-url]",function(){if($(this).attr("contenteditable","false"),$(this).text()!==$(this).data("editable-original"))return confirm("Do you want to save your change? ")?e($(this)):$(this).text($(this).data("editable-original"))}),$(document).on("keypress","[data-editable-url]",function(t){var n;return n=t.keyCode?t.keyCode:t.which,13===n&&($(this).attr("contenteditable","false"),e($(this))),!0})},$(document).ready(e),$(document).on("turbolinks:load",e)}).call(this);
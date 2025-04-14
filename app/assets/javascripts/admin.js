//= require jquery.remotipart
//= require jquery.appear.js.js
//= require jquery-timeago
//= require twitter/bootstrap
//= require typeahead.js.js
//= require bootstrap-tagsinput
//= require bootstrap-datepicker
//= require react
//= require js-routes
//= require axios
//= require underscore
//= require jsdiff

//= require_tree ./overrides
//= require_tree ./modules
//= require_tree ./pages

// shim for pretty file uploads, borrowed from http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
$(document).on('ready', function() {

  $('.btn-file :file').on('change', function() {
    var input = $(this),
        numFiles = input.get(0).files ? input.get(0).files.length : 1,
        label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
      input.trigger('fileselect', [numFiles, label]);
  });

  $('.btn-file').on('fileselect', function(e, numFiles, label) {
    $(this).parent().find('#filepath').text(label);
  });
});

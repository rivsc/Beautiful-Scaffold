//= require jquery3
//= require jquery-ui
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require a-wysihtml5-0.3.0.min
//= require moment
//= require moment/fr
//= require tempusdominus-bootstrap-4.js
//= require bootstrap-datetimepicker-for-beautiful-scaffold
//= require bootstrap-wysihtml5
//= require jstree.min.js
//= require jquery-barcode
//= require beautiful_scaffold
//= require fixed_menu

function initPage(){

    <!-- Insert your javascript here -->

    datetimepicker_init();
    bs_init();
    modify_dom_init();
}
$(function() {
    initPage();
    function startSpinner(){
      $('.loader').show();
    }
    function stopSpinner(){
      $('.loader').hide();
    }
    document.addEventListener("turbolinks:request-start", startSpinner);
    document.addEventListener("turbolinks:request-end", stopSpinner);
    document.addEventListener("turbolinks:render", stopSpinner);
});
$(window).bind('turbolinks:render', function() {
    initPage();
});
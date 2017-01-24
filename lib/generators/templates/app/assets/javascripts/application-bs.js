//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require a-wysihtml5-0.3.0.min
//= require bootstrap-colorpicker
//= require bootstrap-datepicker
//= require bootstrap-timepicker
//= require bootstrap-datetimepicker-for-beautiful-scaffold
//= require bootstrap-wysihtml5
//= require jquery.jstree
//= require tagit.js
//= require chardinjs
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
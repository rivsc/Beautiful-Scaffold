//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap/bootstrap-transition
//= require twitter/bootstrap/bootstrap-alert
//= require twitter/bootstrap/bootstrap-modal
//= require twitter/bootstrap/bootstrap-button
//= require twitter/bootstrap/bootstrap-collapse
//= require twitter/bootstrap/bootstrap-dropdown
//= require twitter/bootstrap/bootstrap-tooltip
//= require jquery.livequery
//= require turbolinks
//= require a-wysihtml5-0.3.0.min
//= require bootstrap-colorpicker
//= require bootstrap-datepicker
//= require bootstrap-timepicker
//= require bootstrap-datetimepicker-for-beautiful-scaffold
//= require bootstrap-wysihtml5
//= require jquery.jstree
//= require jquery.markitup
//= require markitup/sets/bbcode/set
//= require markitup/sets/default/set
//= require markitup/sets/html/set
//= require markitup/sets/markdown/set
//= require markitup/sets/textile/set
//= require markitup/sets/wiki/set
//= require tagit.js
//= require chardinjs
//= require beautiful_scaffold
//= require fixed_menu

function initPage(){
    datetimepicker_init();
    bs_init();
    modify_dom_init();
}
$(function() {
    initPage();
});
$(window).bind('page:change', function() {
    initPage();
});
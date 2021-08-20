function bs_init(){

    // DriverJS
    var driver;
    driver = new Driver();
    $(document).on('click', '#bs-help', function(){
        console.log('allo');
        var elements = $('*[data-present-order]').sort(function(a,b) { return parseInt($(a).attr('data-present-order')) > parseInt($(b).attr('data-present-order')); }).map(function(){
            var elt = $(this);
            return { element: "#" + elt.attr('id'), popover: {
                    title: elt.attr('data-present-title'),
                    description: elt.attr('data-present-description')
                }};
        });

        driver.defineSteps(elements);
        driver.start();
        return false;
    });

    // habtm (select2 - tag)
    $('.bs-tagit').each(function( index ) {
        var tagitelt = this;
        $(tagitelt).select2({
            ajax: {
                processResults: function (data) {
                    // Transforms the top-level key of the response object from 'items' to 'results'
                    return {
                        results: $.map(data, function (obj) {
                            obj.id = obj.id;
                            obj.text = obj.caption;
                            return obj;
                        })
                    };
                }
            }
        });
    });

    // Wysiwyg field
    $('.wysiwyg-editor').wysihtml5({"html": true});

    // Processing
    $(document).on('click', '#checkall', function(){
        $('.cbbatch').prop('checked', this.checked);
    });

    // Filter columns
    $(document).on('click', '#filter-columns', function(){
        var return_json = [];
        $.each($('input[name^="field"]:checked'), function(index, value) {
            return_json.push($(value).val());
        });
        var url = $(this).attr('data-url');
        $.ajax({
            url: url,
            data: { 'fields' : return_json },
            success: function(data) {
                $('table.table th[class^="bs-col"], table.table td[class^="bs-col"]').css('display', 'none');
                $.each(return_json, function(index, value) {
                    $('table.table th.bs-col-' + value + ', table.table td.bs-col-' + value).css('display', 'table-cell');
                });
                $('div[class^="bs-col"]').css('display', 'none');
                $.each(return_json, function(index, value) {
                    $('div.bs-col-' + value).css('display', 'inline');
                });
                $('#modal-columns').modal('hide');
            }
        });
        return false;
    });
    $(document).on('click', '#cancel-filter-columns', function(){
        $('#modal-columns').modal('hide');
        return false;
    });

    // TreeView JS
    var opened = eval($("#treeview").attr("data-opened"));
    var url = $("#treeview").attr("data-url");
    var model = $("#treeview").attr("data-model");
    $("#treeview").on("move_node.jstree", function (e, data) {
        var dataajax = {
            "operation" : "move_node",
            "position" : data.position
        };
        dataajax[model + "_id"] = $('#' + data.parent).attr('data-id');
        $.ajax({
            async : false,
            type: 'POST',
            url: url + data.node.data.id + "/treeview_update",
            data : dataajax,
            success : function (r) {

            },
            error : function (r) {
                $.jstree.rollback(data.rlbk);
            }
        });
    }).jstree({
        "plugins" : [
            "themes","html_data","ui","dnd"
        ],
        "core" : {
            "initially_open" : [opened],
            check_callback: function (op, node, parent, position, more) {
                return true;
            }
        }
    });

    $('.barcode').each(function(index){
        $(this).barcode($(this).attr('data-barcode'), $(this).attr('data-type-barcode'));
    });

    // Add Error Form style with bootstrap
    $("div.form-group>div.field_with_errors").find('.form-control').addClass("is-invalid");
    $("div.form-group>div.field_with_errors").find('label').addClass("text-danger");
    $("#error_explanation").addClass("text-danger");

    // Collapse without IDS (next) TODO bootstrap 4.2
    $('body').on('click.collapse-next.data-api', '[data-toggle=collapse-next]', function() {
        var $target = $(this).parent().next();
        $target.collapse('toggle');
        return false;
    });

    // Mass inserting set focus
    $(function() {
        var elt = $('form.mass-inserting input.form-control').first();
        if($('form.mass-inserting').hasClass('setfocus')){
            elt.focus();
        }
    });

    // Menu dropdown
    try{
        $('.dropdown-toggle').dropdown();
        $('.dropdown-menu').find('form').click(function (e) {
            e.stopPropagation();
        });
    }catch (e){
    }

    // Toggle display Search
    $(document).on('click','#hide-search-btn',function(){
        $('body div.filler div.col-md-9').addClass('col-md-12');
        $('body div.filler div.col-md-12').removeClass('col-md-9');
        $('body div.filler div.col-md-3').hide();
        $('#hide-search-btn').hide();
        $('#show-search-btn').show();
    });
    $(document).on('click','#show-search-btn',function(){
        $('body div.filler div.col-md-12').addClass('col-md-9');
        $('body div.filler div.col-md-9').removeClass('col-md-12');
        $('body div.filler div.col-md-3').show();
        $('#hide-search-btn').show();
        $('#show-search-btn').hide();
    });
    $('#show-search-btn').hide();
}
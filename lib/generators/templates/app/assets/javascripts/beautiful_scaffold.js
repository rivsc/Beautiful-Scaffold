function bs_init(){

    /* Richtext editor */
    $('.select-richtext').click(function(){
        $('.label-richtext-type[for=' + $(this).attr('id') + ']').trigger('click');
    });
    $(document).on("click", '.label-richtext-type', function(){
        elt = $('#' + $(this).attr('for'));
        newSet = elt.val();
        idspleditor = elt.attr('data-spleditor');
        ideditor = elt.attr('data-editor');
        $('#' + idspleditor).markItUpRemove();
        if(!$('#' + idspleditor).hasClass('markItUpEditor')){
            switch(newSet) {
                case 'bbcode':
                    $('#' + idspleditor).markItUp(myBbcodeSettings);
                    break;
                case 'wiki':
                    $('#' + idspleditor).markItUp(myWikiSettings);
                    break;
                case 'textile':
                    $('#' + idspleditor).markItUp(myTextileSettings);
                    break;
                case 'markdown':
                    $('#' + idspleditor).markItUp(myMarkdownSettings);
                    break;
                case 'html':
                    $('#' + idspleditor).markItUp(myHtmlSettings);
                    break;
            }
        }
        $('#' + ideditor).removeClass("bbcode html markdown textile wiki").addClass(newSet);
        return true;
    });

    // Tagit
    $('.bs-tagit').each(function( index ) {
        var tagitelt = this;
        $(tagitelt).tagit({
            tagSource : function( request, response ) {

                var par = $(tagitelt).attr("data-param");
                var url = $(tagitelt).attr("data-url");
                var result = $(tagitelt).attr("data-result");
                var data_to_send = {
                    "skip_save_search": true
                };
                data_to_send[par] = request.term;
                $.ajax({
                    url: url,
                    type: "POST",
                    data: data_to_send,
                    dataType: "json",
                    success: function( data ) {
                        response( $.map( data, function( item ) {
                            return { label: String(item[result]), value: item.id };
                        }));
                    }
                });
            },
            triggerKeys:['enter', 'comma', 'tab'],
            select : true,
            allowNewTags : false
        });
    });

    // Wysiwyg and color field
    $('.wysiwyg-editor').wysihtml5({"html": true});
    $('.color').colorpicker({format: 'rgba'});

    // Processing
    $(document).on('click', '#checkall', function(){
        $('.cbbatch').attr('checked', ($(this).attr('checked') != undefined));
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
    $("#treeview")
        .jstree({
            "plugins" : [
                "themes","html_data","ui","dnd"
            ],
            "core" : {
                "initially_open" : [opened]
            }
        })
        .bind("move_node.jstree", function (e, data) {
            data.rslt.o.each(function (i) {
                var dataajax = {
                    "operation" : "move_node",
                    "position" : data.rslt.cp + i,
                    "title" : data.rslt.name,
                    "copy" : data.rslt.cy ? 1 : 0
                };
                dataajax[model + "_id"] = data.rslt.cr === -1 ? "" : data.rslt.np.data("id");
                $.ajax({
                    async : false,
                    type: 'POST',
                    url: url + $(this).data("id") + "/treeview_update",
                    data : dataajax,
                    success : function (r) {
                        $(data.rslt.oc).attr("id", "treeelt_" + r.id);
                        if(data.rslt.cy && $(data.rslt.oc).children("UL").length) {
                            data.inst.refresh(data.inst._get_parent(data.rslt.oc));
                        }
                    },
                    error : function (r) {
                        $.jstree.rollback(data.rlbk);
                    }
                });
            });
        });

    // Barcode
    $('.barcode').each(function(index){
        $(this).barcode($(this).attr('data-barcode'), $(this).attr('data-type-barcode'));
    });

    // Chardinjs (overlay instructions)
    $(document).on("click", ".bs-chardinjs", function(){
        var selector = $(this).attr("data-selector");
        $(selector).chardinJs('toggle');
        return false;
    });

    // Add Error Form style with bootstrap
    $("div.form-group>div.field_with_errors").parent().addClass("has-error");
    $("#error_explanation").addClass("text-error");

    // Collapse without IDS (next)
    $('body').on('click.collapse-next.data-api', '[data-toggle=collapse-next]', function() {
        var $target = $(this).parent().next();
        $target.data('collapse') ? $target.collapse('toggle') : $target.collapse()
        return false;
    });

    // Mass inserting set focus
    $(function() {
        var elt = $('form.mass-inserting div[style*="inline"][class*="bs-col"] input').first();
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

}
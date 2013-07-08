function bs_init(){

    /* Richtext editor */
    $('.select-richtext').click(function(){
        $('.label-richtext-type[for=' + $(this).attr('id') + ']').trigger('click');
    });
    $('.label-richtext-type').live("click", function(){
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
    $('#checkall').click(function(){
        $('.cbbatch').attr('checked', ($(this).attr('checked') != undefined));
    });

    // Filter columns
    $('#filter-columns').on('click', function(){
        var return_json = [];
        $.each($('input[name^="field"]:checked'), function(index, value) {
            return_json.push($(value).val());
        });
        var url = $(this).attr('data-url');
        $.ajax({
            url: url,
            data: { 'fields' : return_json },
            success: function(data) {
                $('table.table th[class^="col"], table.table td[class^="col"]').css('display', 'none');
                $.each(return_json, function(index, value) {
                    $('table.table th.col-' + value + ', table.table td.col-' + value).css('display', 'table-cell');
                });
                $('div[class^="col"]').css('display', 'none');
                $.each(return_json, function(index, value) {
                    $('div.col-' + value).css('display', 'inline');
                });
                $('#modal-columns').modal('hide');
            }
        });
        return false;
    });
    $('#cancel-filter-columns').on('click', function(){
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

    // Mass inserting set focus
    elt = $('form.mass-inserting div[style*="inline"][class*="col"] .input-small').first();
    if($('form.mass-inserting').hasClass('setfocus')){
        $(elt).focus();
    }

    // Menu dropdown
    try{
        $('.dropdown-toggle').dropdown();
        $('.dropdown-menu').find('form').click(function (e) {
            e.stopPropagation();
        });
    }catch (e){
    }

}
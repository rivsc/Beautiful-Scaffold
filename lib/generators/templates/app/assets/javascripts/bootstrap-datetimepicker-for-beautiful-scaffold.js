$('.dropdown-toggle').dropdown();
$('.dpicker').livequery(function(){
    $(this).datepicker({ format : 'dd/mm/yyyy', language : $('html').attr("lang") }).on('changeDate', function(ev){
        idday   = '#' + $('#' + ev.currentTarget.id).data('id') + '_3i';
        idmonth = '#' + $('#' + ev.currentTarget.id).data('id') + '_2i';
        idyear  = '#' + $('#' + ev.currentTarget.id).data('id') + '_1i';
        $(idday).val(ev.date.getDate());
        $(idmonth).val(ev.date.getMonth()+1);
        $(idyear).val(ev.date.getFullYear());
    });
    $(this).change(function(){
        if( !$(this).val() ){
            id = '#' + $(this).data('id');
            $(id + '_3i').val("");
            $(id + '_2i').val("");
            $(id + '_1i').val("");
        }
    });
});
$('.add-on').live('click', function(){
    try{
        dpick = $(this).parent().find('.dpicker');
        dpick.trigger('focus');
        dpick.trigger('select');
    }catch (e){
    }
});
$('.tpicker').livequery(function(){
    $(this).timepicker({ template: 'modal', showMeridian: false, minuteStep: 1, defaultTime: false, showInputs: false, disableFocus: true }).on('change', function(ev){
        tpickerdate = new Date("01/01/1970 " + ev.currentTarget.value);
        idhour   = '#' + $('#' + ev.currentTarget.id).data('id') + '_4i';
        idmin    = '#' + $('#' + ev.currentTarget.id).data('id') + '_5i';
        $(idhour).val(tpickerdate.getHours());
        $(idmin).val(tpickerdate.getMinutes());
    });
    $(this).change(function(){
        if( !$(this).val() ){
            id = '#' + $(this).data('id');
            $(id + '_4i').val("");
            $(id + '_5i').val("");
        }
    });
});
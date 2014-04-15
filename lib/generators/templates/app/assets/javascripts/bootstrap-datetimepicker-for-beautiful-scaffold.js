function datetimepicker_init(){
    $(document).on('click', '.dpicker', function(e){
        e.stopPropagation();
        e.stopImmediatePropagation();
        $(this).datepicker({ format : 'dd/mm/yyyy', language : $('html').attr("lang") }).on('changeDate', function(ev){
            var eltid = ev.currentTarget.id;
            //eltid = $('#' + ev.currentTarget.id).data('id');
            $('#' + eltid + '_3i').val(ev.date.getDate());          // Day
            $('#' + eltid + '_2i').val(ev.date.getMonth()+1);       // Month
            $('#' + eltid + '_1i').val(ev.date.getFullYear());      // Year
        });
        $(this).change(function(){
            if( !$(this).val() ){
                id = '#' + $(this).data('id');
                $(id + '_3i').val("");
                $(id + '_2i').val("");
                $(id + '_1i').val("");
            }
        });
        $(this).trigger('focus');
        $(this).trigger('select');
    });
    $(document).on('click', '.input-group-addon', function(){
        try{
            dpick = $(this).parent().find('.dpicker');
            dpick.trigger('focus');
            dpick.trigger('select');
        }catch (e){
        }
    });
    $(document).on('click', '.tpicker', function(){
        $(this).timepicker({ template: 'modal', showMeridian: false, minuteStep: 1, defaultTime: false, showInputs: false, disableFocus: true }).on('change', function(ev){
            tpickerdate = new Date("01/01/1970 " + ev.currentTarget.value);
            var eltid = ev.currentTarget.id;
            //eltid = $('#' + ev.currentTarget.id).data('id');
            $('#' + eltid + '_4i').val(tpickerdate.getHours());  // Hour
            $('#' + eltid + '_5i').val(tpickerdate.getMinutes()); // Min
        });
        $(this).change(function(){
            if( !$(this).val() ){
                id = '#' + $(this).data('id');
                $(id + '_4i').val("");
                $(id + '_5i').val("");
            }
        });
        $(this).click();
    });
}
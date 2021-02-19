function datetimepicker_init(){
    $('.tpicker').datetimepicker({ format: 'LT', widgetPositioning: {
            horizontal: 'auto',
            vertical: 'auto'
        } });
    $('.tpicker').on('change.datetimepicker', function(elt){
        var eltid = $(elt.target).attr('data-field');
        $('#' + eltid + '4i').val(elt.date.hour());
        $('#' + eltid + '5i').val(elt.date.minute());
    });
    $('.dpicker').datetimepicker({ format: 'L', widgetPositioning: {
            horizontal: 'auto',
            vertical: 'auto'
        } });
    $('.dpicker').on('change.datetimepicker', function(elt){
        var eltid = $(elt.target).attr('data-field');
        $('#' + eltid + '3i').val(elt.date.date());
        $('#' + eltid + '2i').val(elt.date.month()+1);
        $('#' + eltid + '1i').val(elt.date.year());
    });
    $(document).on('click', '.dpicker', function(e){
        $(this).datetimepicker('show');
    });
    $(document).on('click', '.tpicker', function(e){
        $(this).datetimepicker('show');
    });
    $(".datetimepicker-input").each(function(i, elt){
        $(elt).removeAttr("name");
    });
}
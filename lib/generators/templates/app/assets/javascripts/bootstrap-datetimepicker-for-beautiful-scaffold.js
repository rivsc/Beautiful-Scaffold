function datetimepicker_init(){
    $('.tpicker').datetimepicker({ format: 'LT' }).on('change.datetimepicker', function(elt){
        console.log('===============> time');
        console.log(elt);
        console.log($(elt.target).attr('data-field'));
        var eltid = $(elt.target).attr('data-field');
        $('#' + eltid + '_4i').val(elt.date.hour());
        $('#' + eltid + '_5i').val(elt.date.minute());
    });

    $('.dpicker').datetimepicker({ format: 'L' }).on('change.datetimepicker', function(elt){
        console.log('===============> date');
        console.log(elt);
        console.log($(elt.target).attr('data-field'));
        var eltid = $(elt.target).attr('data-field');
        $('#' + eltid + '_3i').val(elt.date.date());
        $('#' + eltid + '_2i').val(elt.date.month()+1);
        $('#' + eltid + '_1i').val(elt.date.year());
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
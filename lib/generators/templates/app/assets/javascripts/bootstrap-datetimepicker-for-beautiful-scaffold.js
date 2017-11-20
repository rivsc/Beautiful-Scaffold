function datetimepicker_init(){
  $(document).on('click', '.dpicker', function(e){
    e.stopPropagation();
    e.stopImmediatePropagation();
    $(this).datetimepicker({
      format : 'DD/MM/YYYY',
      locale : 'en',
      icons: {
        time: "fa fa-clock-o",
        date: "fa fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
      }
    }).on('dp.change', function(elt){
      var eltid = elt.currentTarget.dataset.id;
      $('#' + eltid + '_3i').val(elt.date.date());
      $('#' + eltid + '_2i').val(elt.date.month()+1);
      $('#' + eltid + '_1i').val(elt.date.year());
    });
    $(this).trigger('focus');
    $(this).trigger('select');
    return false;
  });
  $(document).on('click', '.tpicker', function(e){
    e.stopPropagation();
    e.stopImmediatePropagation();
    $(this).datetimepicker({
      format : 'HH:mm',
      locale : 'en',
      icons: {
        time: "fa fa-clock-o",
        date: "fa fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
      }
    }).on('dp.change', function(elt){
      var eltid = elt.currentTarget.dataset.id;
      $('#' + eltid + '_4i').val(elt.date.hour());
      $('#' + eltid + '_5i').val(elt.date.minute());
    });
    $(this).trigger('focus');
    $(this).trigger('select');
    return false;
  });
}